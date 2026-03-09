#!/usr/bin/env python3
# ===========================================
# Telegram Notification Script for CI/CD
# ===========================================
# Usage: python notify_telegram.py --status success --build 123 --platform android
# ===========================================

import os
import sys
import json
import argparse
from urllib.request import Request, urlopen
from urllib.error import URLError
from urllib.parse import quote
from datetime import datetime

# Configuration
TELEGRAM_BOT_TOKEN = os.environ.get('TELEGRAM_BOT_TOKEN', '')
TELEGRAM_CHAT_ID = os.environ.get('TELEGRAM_CHAT_ID', '')
PROJECT_NAME = 'PassGen'

def parse_args():
    parser = argparse.ArgumentParser(description='Send Telegram notifications')
    parser.add_argument('--status', required=True, choices=['success', 'failure', 'started', 'cancelled'],
                        help='Build status')
    parser.add_argument('--build', default='N/A', help='Build number')
    parser.add_argument('--platform', default='unknown', help='Platform (android/ios/web/desktop)')
    parser.add_argument('--message', default='', help='Additional message')
    parser.add_argument('--author', default='CI/CD', help='Build author/trigger')
    parser.add_argument('--commit', default='', help='Commit SHA')
    parser.add_argument('--branch', default='', help='Branch name')
    parser.add_argument('--duration', default='', help='Build duration')
    parser.add_argument('--bot-token', default='', help='Override bot token')
    parser.add_argument('--chat-id', default='', help='Override chat ID')
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

def build_message(args):
    """Build Telegram message"""
    emoji = get_status_emoji(args.status)
    timestamp = datetime.now().strftime('%Y-%m-%d %H:%M:%S UTC')
    
    # Build message text
    lines = [
        f'{emoji} *Build {args.status.capitalize()}*',
        '',
        f'*Project:* {PROJECT_NAME}',
        f'*Platform:* {args.platform.capitalize()}',
        f'*Build #:* `{args.build}`',
        f'*Status:* {args.status.capitalize()}',
    ]
    
    if args.branch:
        lines.append(f'*Branch:* `{args.branch}`')
    
    if args.commit:
        short_commit = args.commit[:7] if len(args.commit) >= 7 else args.commit
        lines.append(f'*Commit:* `{short_commit}`')
    
    if args.duration:
        lines.append(f'*Duration:* {args.duration}')
    
    if args.author:
        lines.append(f'*Triggered By:* {args.author}')
    
    if args.message:
        lines.append('')
        lines.append(f'_{args.message}_')
    
    lines.append('')
    lines.append(f'_{timestamp}_')
    
    return '\n'.join(lines)

def build_inline_keyboard(args):
    """Build inline keyboard with action buttons"""
    keyboard = []
    
    # Add buttons based on status
    if args.status == 'failure':
        keyboard.append([
            {'text': '📋 View Logs', 'callback_data': 'view_logs_' + str(args.build)},
            {'text': '🔁 Retry Build', 'callback_data': 'retry_build_' + str(args.build)}
        ])
    
    if args.platform in ['android', 'ios']:
        keyboard.append([
            {'text': '📥 Download', 'callback_data': 'download_' + args.platform + '_' + str(args.build)}
        ])
    
    return {'inline_keyboard': keyboard} if keyboard else {}

def send_notification(message, bot_token, chat_id, reply_markup=None):
    """Send notification to Telegram"""
    if not bot_token or not chat_id:
        print('Error: Telegram bot token or chat ID not configured')
        return False
    
    url = f'https://api.telegram.org/bot{bot_token}/sendMessage'
    
    payload = {
        'chat_id': chat_id,
        'text': message,
        'parse_mode': 'Markdown',
        'disable_web_page_preview': True
    }
    
    if reply_markup:
        payload['reply_markup'] = json.dumps(reply_markup)
    
    try:
        data = json.dumps(payload).encode('utf-8')
        req = Request(
            url,
            data=data,
            headers={'Content-Type': 'application/json'}
        )
        response = urlopen(req, timeout=10)
        result = json.loads(response.read().decode('utf-8'))
        
        if result.get('ok'):
            print('Notification sent successfully')
            return True
        else:
            print(f'Failed to send notification: {result.get("description", "Unknown error")}')
            return False
            
    except URLError as e:
        print(f'Error sending notification: {e}')
        return False
    except Exception as e:
        print(f'Unexpected error: {e}')
        return False

def main():
    args = parse_args()
    
    # Build message
    message = build_message(args)
    
    # Build inline keyboard
    reply_markup = build_inline_keyboard(args)
    
    # Use override credentials if provided
    bot_token = args.bot_token or TELEGRAM_BOT_TOKEN
    chat_id = args.chat_id or TELEGRAM_CHAT_ID
    
    # Send notification
    success = send_notification(message, bot_token, chat_id, reply_markup)
    
    sys.exit(0 if success else 1)

if __name__ == '__main__':
    main()
