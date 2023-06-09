#!/bin/bash

set -e

export SD_UI_PATH=/easy-diffusion-app/easy-diffusion/ui
cd /easy-diffusion-app/easy-diffusion/stable-diffusion

uvicorn main:server_api --app-dir "$SD_UI_PATH" --port ${SD_UI_BIND_PORT:-9000} --host ${SD_UI_BIND_IP:-0.0.0.0} --log-level error