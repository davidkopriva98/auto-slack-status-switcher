from datetime import datetime, timedelta
import logging, os, time, subprocess, requests

logging.basicConfig(filename='python.log', level=logging.DEBUG)

slack_set_status_url = "https://slack.com/api/users.profile.set"

def is_time_between_hours(between_hours: str):
    current_hour = datetime.now().hour
    start_hour, end_hour = map(int, between_hours.split('-'))
    return start_hour <= current_hour <= end_hour

def is_on_wifi(wifi: str):
    output = subprocess.check_output("netsh wlan show interfaces").decode('utf-8')
    return wifi in output

def is_status_currently_set(user_id: str, access_token: str):
    logging.info(f"Getting slack status for user: {user_id}")

    api_url = f"https://slack.com/api/users.profile.get?user={user_id}"
    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/x-www-form-urlencoded"
    }

    response = requests.get(api_url, headers=headers)

    if response.ok:
        data = response.json()
        status_emoji = data["profile"]["status_emoji"]
        status_message = data["profile"]["status_text"]

        # Uncomment the line below to print the status emoji and status message
        # print(f"Status emoji: {status_emoji} and status message: {status_message}")

        return not (status_message is None or status_emoji is None or status_message == "" or status_emoji == "")
    else:
        logging.info(f"Error: {response.json()['error']}")
        return True
    
def update_status(new_status_text: str, new_status_emoji: str, access_token: str):
    logging.info("Updating Slack status")

    current_date = datetime.now().date()
    end_of_day = datetime.combine(current_date, datetime.max.time()) - timedelta(microseconds=1)
    end_of_day_timestamp = int(end_of_day.timestamp())

    payload = {
        "profile": {
            "status_text": new_status_text,
            "status_emoji": new_status_emoji,
            "status_expiration": end_of_day_timestamp
        }
    }

    headers = {
        "Authorization": f"Bearer {access_token}",
        "Content-Type": "application/json"
    }

    response = requests.post(slack_set_status_url, json=payload, headers=headers)

    if response.ok:
        logging.info("Slack status updated successfully.")
        return True
    else:
        logging.info(f"Failed to update Slack status. Error: {response.json()['error']}")
        return False


def clear_toasts_and_shutdown(interactableToaster):
    time.sleep(10)
    interactableToaster.clear_toasts()
    shutdown()

def shutdown():
    logging.info("Shutting down...")
    os._exit(0)
    