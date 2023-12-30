#
# Slack Client
#
# Per Workspace: Authorization
#
#   0. Go to https://my.slack.com/customize
#   1. Paste and run this code: window.prompt("Session token:", TS.boot_data.api_token)
#   2. A prompt with the token will appear. Copy the token.
#   3. In the developer console go to Application in Chrome or Storage in Firefox.
#   4. Expand Cookies and click on the domain.
#   5. Find the cookie named d and copy the value.
#   6. Store the value in the "credentials" field like: "xorc-....,xord-...."
#
# Source:
# https://github.com/wee-slack/wee-slack?tab=readme-ov-file#get-a-session-token
#

load("http.star", "http")
load("render.star", "render")
load("schema.star", "schema")
load("time.star", "time")
load("encoding/base64.star", "base64")
load("encoding/json.star", "json")

START_TIME = time.now()
LAST_READ_FLOOR = START_TIME + time.parse_duration("72h")
DEBUG = False

# --------------------------------------------
# Fetching
# --------------------------------------------

def UnreadResult(count, channels, users):
    return struct(
        count=count,
        channels=channels,
        users=users,
        ok=True,
        error="",
    )

def UnreadError(error):
    return struct(
        count=0,
        channels=0,
        users=0,
        ok=False,
        error=error,
    )


def fetch_unread_messages(creds):
    """
    Get all the unread messages directed directly to the user.

    This it *not* an efficient way to do this it the number of
    requests is O(#of channels + #of direct chats).
    """

    # Fetch the list of channels
    channels_result = slack_request(
        creds=creds,
        method="https://slack.com/api/conversations.list",
        types="public_channel,private_channel,mpim,im",
    )

    if not channels_result.ok:
        return UnreadError("List: %s" % channels_result.error)

    channels = channels_result.data["channels"]

    # Iterate through each channel accumulating the unread counts.
    channel_count = 0
    user_count = 0
    unread_count = 0

    log("Checking channel count: %d" % len(channels))
    for channel in channels:
        # Print the name
        is_im = channel["is_im"]
        if is_im:
            name = channel["user"]
            user_count += 1
        else:
            name = channel.get("name_normalized")
            channel_count += 1

        # Grab converstation info.
        channel_id = channel["id"]

        log("  NAME: %s (%s)" % (name, channel_id))

        info_result = slack_request(
            creds=creds,
            method="https://slack.com/api/conversations.info",
            channel=channel_id,
        )

        if not info_result.ok:
            continue

        info = info_result.data

        if is_im:
            unread_count += unread_from_im(creds, info, name)
        else:
            unread_count += unread_from_channel(creds, info, channel)

    return UnreadResult(
        count=unread_count,
        channels=channel_count,
        users=user_count,
    )


def unread_from_im(creds, info, name):
    """
    Get the unread count for direct messages based on provided slack value.
    """
    # username = fetch_username(creds, name).username

    return int(info["channel"]["unread_count_display"])


def unread_from_channel(creds, info, channel):
    """
    Get the unread count for channels based on the last read time
    and returned history values.
    """

    # Use the last_read with conversation.history, remember to set the
    # limit to only get the messages we need
    last_read = float(info["channel"]["last_read"])

    usable_last_read = max(last_read, float(LAST_READ_FLOOR.unix))

    log("    LAST TIME: %f" % usable_last_read)

    # Fetch messages from the channel
    messages_result = slack_request(
        creds=creds,
        method="https://slack.com/api/conversations.history",
        channel=channel["id"],
        oldest="%f" % usable_last_read,
    )

    if not messages_result.ok:
        return 0

    messages = messages_result.data["messages"]

    return len(messages)


def fetch_workspace(creds):
    result = slack_request(
        creds=creds,
        method="https://slack.com/api/auth.test",
    )

    if not result.ok:
        return struct(
            ok=False,
            error=result.error,
        )

    return struct(
        ok=True,
        team=result.data["team"],
        user=result.data["user"],
    )


def fetch_username(creds, userid):
    result = slack_request(
        creds=creds,
        method="https://slack.com/api/users.info",
        user=userid,
    )

    if not result.ok:
        return struct(
            ok=False,
            error=result.error,
        )

    return struct(
        ok=True,
        username=result.data["user"]["name"],
    )


# --------------------------------------------
# Requests
# --------------------------------------------

def RequestResult(data):
    return struct(
        data=data,
        ok=True,
        error="",
    )

def RequestError(error):
    return struct(
        data={},
        ok=False,
        error=error,
    )

def slack_request(creds, method, **params):
    """
    Make a get request on the desired API method.

    The authorization here is very intense because slack does not
    really support building your own slack clients which is what this
    essentially is.
    """
    headers = {
        "Authorization": "Bearer %s" % creds.token,
        "Cookie": "d=%s" % creds.cookie,
    }

    log("METHOD: %s" % method)
    log("  PARAMS: %s" % params)

    parts = []
    for entry in params.items():
        parts.append('%s=%s' % entry)
    request = method + ("" if len(parts) == 0 else "?%s" % "&".join(parts))

    log("  REQUEST: %s" % request)
    response = http.get(request, headers=headers)

    log("  STATUS CODE: %d" % response.status_code)
    if response.status_code != 200:
        return RequestError("Return code: %d" % response.status_code)

    data = response.json()
    if not data["ok"]:
        elog(method, data["error"])
        return RequestError(data["error"])

    return RequestResult(data)


# --------------------------------------------
# Utility
# --------------------------------------------

def Credentials(token, cookie):
    """
    Login credentials for a slack account.
    """
    return struct(token=token, cookie=cookie)


def parse_credentials(s):
    """
    Takes in a set of workspace credentials in the form of:

    token,cookiee
    """

    parts = s.split(",")
    part_count = len(parts)

    if part_count != 2:
        fail("Invalid token format, found %d parts, format it 'token,cookie'" % part_count)
    return Credentials(token=parts[0], cookie=parts[1])



def pretty_print(obj):
    """
    Pretty prints a object.
    """
    s = json.encode(obj)
    print(json.indent(s))


def log(msg):
    """
    Only pring messages when DEBUG is true.
    """
    if DEBUG:
        print(msg)


def elog(etype, msg):
    """
    Always print error messages.
    """
    print("ERROR[%s]: %s" % (etype, msg))


# --------------------------------------------
# Main
# --------------------------------------------

def main(config):
    start = time.now()
    log("START")

    # Gather data
    creds = parse_credentials(config.get("slack_credentials"))
    result = get_data(creds)

    # Render
    rendered = render_data(result)

    # Debug information.
    duration = time.now() - START_TIME

    print("""\nUNREAD: {r}
CHECKED:
  IMs:      {u}
  CHANNELs: {c}
DURATION: {d}""".format(
        r=result.count,
        u=result.users,
        c=result.channels,
        d=duration,
    ))

    return rendered


def get_data(creds):
    auth = fetch_workspace(creds)
    if auth.ok:
        print("\nUSER: %s\nTEAM: %s" % (auth.user, auth.team))

    return fetch_unread_messages(creds)


def render_data(result):
    # Render
    count = 0

    if not result.ok:
        widget = render.Marquee(
            child=render.Text("ERROR: %s" % result.error),
            width=64,
        )
    else:
        count = result.count
        widget = render.Circle(
            color="#f00",
            diameter=10,
            child=render.Text("%s" % count)
        )

    return render.Root(
        child = render.Row(
            expanded=True,
            cross_align="center",
            children=[
                render.Image(src=SLACK_ICON),
                widget,
            ],
        )
    )



def get_schema():
    return schema.Schema(
        version = "1",
        fields = [
            schema.Text(
                id = "slack_credentials",
                name = "SLACK_CREDENTIALS",
                desc = "Slack API Token",
                icon = "key",
                default = "",
            ),
        ],
    )


# --------------------------------------------
# Images
# --------------------------------------------

SLACK_ICON = base64.decode("iVBORw0KGgoAAAANSUhEUgAAABAAAAAQCAYAAAAf8/9hAAAAAXNSR0IArs4c6QAAAARnQU1BAACxjwv8YQUAAAAJcEhZcwAADsMAAA7DAcdvqGQAAAHHSURBVDhPtVE9T8JQFO2iEHRAo4OJwMJE2sdQaeJH4uoP0KE4+JGIJpqIODjY2h8hGkP8BSym1YJODFAnfoGJVo0MBkjrIJNY7y0PVDRMepKTl/fePfedcx/zLxAMa1UoWUczRXsocqkMc7p8zOoHK/S6N2YLjhfETcGwnVjJShFdTpGc7JC81CRXuwO0rDcE4yUjXFu3QtHeIrokuw2AvKaM0JKf4MsVH1puM5x79+D5bw1CBcWLawc0s2u7zVjJbkwYL1PdDThdOsU432YCWdNfxZ9NrDWYwQaK2Zz0ii9zefmp1VA6pHKGQcuQORkzrL0OQcyXnb5IVunn9IM1Ni9PYi2n72+Ci+3omeJ3xYjH8flhM7CYvA/GN3EP6/RDMJ4o84k+Jxvpr6pcoqqye23WVC5pX3BDrhgBgiOgYwbFJzO05DWD8Qbu7wLielWLrtc04nSzqpHPCOa4uALiJohOKmPiCIpbFOW6Gp2ua2zjm/icNMHFEpW3cBOec7+tu4F7lwt70HKbFY334fmv6G5QU9mtmkpugRla0hvPowuDNI5jBuI7dY2kWpnZN3RCy3rDnUlATMNA/WgZXk9D5mV6/ZdgmA8XJDVdMignqAAAAABJRU5ErkJggg==")
