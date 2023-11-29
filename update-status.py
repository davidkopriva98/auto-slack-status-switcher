from windows_toasts import InteractableWindowsToaster, Toast, ToastActivatedEventArgs, ToastButton, ToastDismissedEventArgs
from dotenv import load_dotenv
import os

from utils import is_on_wifi, is_status_currently_set,is_time_between_hours, update_status, clear_toasts_and_shutdown, shutdown
import logging

logging.basicConfig(filename='python.log', level=logging.DEBUG)

def update_slack():
    response = update_status(new_status_text, new_status_emoji, access_token)

    toast = Toast()
    if response is True:
        toast.text_fields = ['Slack status was updated','Slack status was successfully updated to ' + new_status_text]
        interactableToaster.show_toast(toast)
        clear_toasts_and_shutdown(interactableToaster)
    else:
        toast.text_fields = ['Error while updating Slack status','An error occurred while updating Slack status']
        interactableToaster.show_toast(toast)
        clear_toasts_and_shutdown(interactableToaster)

def activated_callback(activatedEventArgs: ToastActivatedEventArgs):
    logging.info(activatedEventArgs.arguments) # response=decent/response=bad
    if activatedEventArgs.arguments == 'response=True':
        update_slack()
    else:
        shutdown()

def dismissed_callback(_: ToastDismissedEventArgs):
    shutdown()

def run_logic():
    load_dotenv()

    global access_token
    access_token = os.getenv("ACCESS_TOKEN")
    user_id = os.getenv("USER_ID")
    between_hours = os.getenv("CHANGE_STATUS_BETWEEN_HOURS")
    work_wifi = os.getenv("WORK_WIFI")
    home_wifi = os.getenv("HOME_WIFI")

    #logging.info("WORK_WIFI: ", work_wifi)
    #logging.info("HOME_WIFI: ", home_wifi)
    logging.info("".join([char*30 for char in "--"]))

    global interactableToaster
    interactableToaster = InteractableWindowsToaster('Automatic Slack status', 'davidkopriva98.automaticslackstatus')
    #toast.AddImage(ToastDisplayImage.fromPath(r'C:\Users\David\Projects\auto-slack-status-switcher\icon.png'))

    on_home_wifi = is_on_wifi(home_wifi)
    on_work_wifi = is_on_wifi(work_wifi)

    #logging.info("on work wifi ", on_work_wifi)
    #logging.info("on home wifi ", on_home_wifi)

    global new_status_text
    global new_status_emoji

    if on_home_wifi is False and on_work_wifi is False:
        logging.info("Device is not connected to known network.")
        toast = Toast()
        toast.text_fields = ['Wi-Fi not recognised.','Slack status was not updated.']
        interactableToaster.show_toast(toast)
        clear_toasts_and_shutdown(interactableToaster)
    elif on_home_wifi is True:
        new_status_text = "Working remotely"
        new_status_emoji = ":house_with_garden:"
    else:
        new_status_text = "Office"
        new_status_emoji = ":office:"

    is_slack_status_set = is_status_currently_set(user_id, access_token)
    is_time_ok = is_time_between_hours(between_hours)

    if is_time_ok is True and is_slack_status_set is False:
        logging.info("Current time is ok and status is not already set.")
        update_slack()
    elif is_slack_status_set is True:
        logging.info("Current time is ok and status is already set.")
        toast = Toast()

        toast.text_fields = ['Slack status is already set','Do you wish to override current Slack status and set the status as ' + new_status_text]
        toast.AddAction(ToastButton('Yes', 'response=True'))
        toast.AddAction(ToastButton('No', 'response=False'))
        toast.on_activated = activated_callback
        toast.on_dismissed = dismissed_callback

        interactableToaster.show_toast(toast)
    else:
        logging.info("Current time is not ok and status is not already set.")
        toast = Toast()

        toast.text_fields = ['Time outside set time','Do you wish ignore set time for update set the status as ' + new_status_text]
        toast.AddAction(ToastButton('Yes', 'response=True'))
        toast.AddAction(ToastButton('No', 'response=False'))
        toast.on_activated = activated_callback
        toast.on_dismissed = dismissed_callback

        interactableToaster.show_toast(toast)

if __name__ == "__main__":
   run_logic()