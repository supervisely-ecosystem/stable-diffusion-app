from easydiffusion import model_manager, renderer
from easydiffusion.utils import log
import os

print("WorkDir:", os.getcwd())

# Init the app
model_manager.init()

device = "cuda:0"  # actually whis name doesn't matter while build image 
renderer.context.device = device

try:
    model_manager.load_default_models(renderer.context)
except Exception as e:
    log.exception("Load models failed.")
