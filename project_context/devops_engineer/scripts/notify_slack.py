#!/usr/bin/env python3
# ===========================================
# Slack Notification Script for CI/CD
# ===========================================
# Usage: python notify_slack.py --status success --build 123 --platform android
# ===========================================

import os
import sys
import json
import argparse
from urllib.request import Request, urlopen
from urllib.error import URLError
from datetime import datetime

# Configuration
SLACK_WEBHOOK_URL = os.environ.get('SLACK_WEBHOOK_URL', '')
SLACK_CHANNEL = os.environ.get('SLACK_CHANNEL', '#ci-cd-notifications')
PROJECT_NAME = 'PassGen'

def parse_args():
    parser = argparse.ArgumentParser(description='Send Slack notifications')
    parser.add_argument('--status', required=True, choices=['success', 'failure', 'started', 'cancelled'],
                        help='Build status')
    parser.add_argument('--build', default='N/A', help='Build number')
    parser.add_argument('--platform', default='unknown', help='Platform (android/ios/web/desktop)')
    parser.add_argument('--message', default='', help='Additional message')
    parser.add_argument('--author', default='CI/CD', help='Build author/trigger')
    parser.add_argument('--commit', default='', help='Commit SHA')
    parser.add_argument('--branch', default='', help='Branch name')
    parser.add_argument('--duration', default='', help='Build duration')
    parser.add_argument('--webhook-url', default='', help='Override webhook URL')
    return parser.parse_args()

def get_status_emoji(status):
    """Return emoji for build status"""
    emojis = {
        'success': '✅',
        'failure': '❌',
        'started': '🔄',
        'cancelled': '⛔'
    }
    return emojis.get(status, '❓')

def get_status_color(status):
    """Return color for Slack attachment"""
    colors = {
        'success': 'good',
        'failure': 'danger',
        'started': 'warning',
        'cancelled': '#808080'
    }
    return colors.get(status, '#808080')

def build_payload(args):
    """Build Slack message payload"""
    emoji = get_status_emoji(args.status)
    color = get_status_color(args.status)
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')
    
    # Build fields
    fields = [
        {'title': 'Project', 'value': PROJECT_NAME, 'short': True},
        {'title': 'Platform', 'value': args.platform.capitalize(), 'short': True},
        {'title': 'Build #', 'value': str(args.build), 'short': True},
        {'title': 'Status', 'value': args.status.capitalize(), 'short': True},
    ]
    
    if args.branch:
        fields.append({'title': 'Branch', 'value': args.branch, 'short': True})
    
    if args.commit:
        short_commit = args.commit[:7] if len(args.commit) >= 7 else args.commit
        fields.append({'title': 'Commit', 'value': f'`{short_commit}`', 'short': True})
    
    if args.duration:
        fields.append({'title': 'Duration', 'value': args.duration, 'short': True})
    
    if args.author:
        fields.append({'title': 'Triggered By', 'value': args.author, 'short': True})
    
    # Build attachment
    attachment = {
        'color': color,
        'title': f'{emoji} Build {args.status.capitalize()}',
        'fields': fields,
        'footer': PROJECT_NAME,
        'ts': int(datetime.now().timestamp())
    }
    
    if args.message:
        attachment['text'] = args.message
    
    # Build payload
    payload = {
        'channel': SLACK_CHANNEL,
        'username': 'CI/CD Bot',
        'icon_emoji': ':robot_face:',
        'attachments': [attachment]
    }
    
    return payload

def send_notification(payload, webhook_url):
    """Send notification to Slack"""
    if not webhook_url:
        print('Error: Slack webhook URL not configured')
        return False
    
    try:
        data = json.dumps(payload).encode('utf-8')
        req = Request(
            webhook_url,
            data=data,
            headers={'Content-Type': 'application/json'}
        )
        response = urlopen(req, timeout=10)
        
        if response.status == 200:
            print('Notification sent successfully')
            return True
        else:
            print(f'Failed to send notification: HTTP {response.status}')
            return False
            
    except URLError as e:
        print(f'Error sending notification: {e}')
        return False
    except Exception as e:
        print(f'Unexpected error: {e}')
        return False

def main():
    args = parse_args()
    
    # Build payload
    payload = build_payload(args)
    
    # Use override webhook URL if provided
    webhook_url = args.webhook_url or SLACK_WEBHOOK_URL
    
    # Send notification
    success = send_notification(payload, webhook_url)
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
