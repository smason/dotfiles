import os
import sys
import json
import argparse

import websocket

class Player(websocket.WebSocket):
    def sendMsg(self, **kwargs):
        self.send(json.dumps(kwargs))

    def sendConnect(self, *args):
        self.sendMsg(
            namespace='connect',
            method='connect',
            arguments=('Sams Controller',)+args,
        )

def default_arg_parser():
    default_url = os.environ.get(
        'GPMDP_WEBSOCKET',"ws://localhost:5672")

    parser = argparse.ArgumentParser(description="Command Line GPMDP Client")
    parser.add_argument('method', help='method to call')
    parser.add_argument('args', metavar='arguments', help='method arguments',
                        nargs=argparse.REMAINDER)
    parser.add_argument('--gpmdp', dest='url', help="GPMDP Websocket URL",
                        default=default_url, metavar='URL')
    parser.add_argument('--verbose', help="Enable verbose output",
                        action='store_true')
    parser.add_argument('--auth', help="Specify authentication token",
                        default=os.environ.get('GPMDP_AUTHTOKEN'))
    return parser

if __name__ == '__main__':
    args = default_arg_parser().parse_args()

    player = Player()
    player.connect(args.url)

    auth_token = args.auth
    if not auth_token:
        player.sendConnect()
        code = sys.stdin.read()
        player.sendConnect(code.strip())

        while True:
            msg = player.recv();
            obj = json.loads(msg)
            if args.verbose and obj.get('channel') in ['queue','library']:
                continue
            sys.stdout.write('{}\n'.format(msg))

        # not sure how I'd get here!
        sys.exit(1)

    player.sendConnect(auth_token)
    player.sendMsg(
        namespace='playback',
        method=args.method,
        arguments=args.args,
        requestID=737,
    )

    # make sure the command gets executed
    while True:
        msg = player.recv();
        obj = json.loads(msg)
        if args.verbose and obj.get('channel') not in ['queue','library']:
            sys.stdout.write('{}\n'.format(msg))
        if obj.get('namespace') == 'result':
            break;
