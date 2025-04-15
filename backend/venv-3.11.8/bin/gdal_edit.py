#!/Users/jacobtang/barbuddy/backend/venv-3.11.8/bin/python3.11

import sys

from osgeo.gdal import deprecation_warn

# import osgeo_utils.gdal_edit as a convenience to use as a script
from osgeo_utils.gdal_edit import *  # noqa
from osgeo_utils.gdal_edit import main

deprecation_warn("gdal_edit")
sys.exit(main(sys.argv))
