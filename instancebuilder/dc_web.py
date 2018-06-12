#!/usr/bin/env python3
"""Docstring for module."""

import sys
import argparse
import os
from elementbase import ElementBase
# ==============================================================================
__version__ = "0.1"

__copyright__ = "Copyright 2017, devops.center"
__credits__ = ["Bob Lozano", "Gregg Jensen"]
__license__ = ' \
   # Copyright 2014-2017 devops.center llc                                    \
   #                                                                          \
   # Licensed under the Apache License, Version 2.0 (the "License");          \
   # you may not use this file except in compliance with the License.         \
   # You may obtain a copy of the License at                                  \
   #                                                                          \
   #   http://www.apache.org/licenses/LICENSE-2.0                             \
   #                                                                          \
   # Unless required by applicable law or agreed to in writing, software      \
   # distributed under the License is distributed on an "AS IS" BASIS,        \
   # WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. \
   # See the License for the specific language governing permissions and      \
   # limitations under the License.                                           \
   # '
__status__ = "Development"
# ==============================================================================


class dcWeb(ElementBase):
    """Class the installs the web components."""

    def __init__(self, argList):
        """Constructor for this class."""
        ElementBase.__init__(self, "web", argList)
        self.executePath = (self.stackDir + "/"
                            + self.stack + "-stack/web")
        self.executeScript = "sudo ./web.sh " + self.region

    def run(self):
        """Run the element to install the corresponding code."""
        # change directory to the dcStack buildtools directory to get the base
        # stuff to install
        currentDir = os.getcwd()
        theDir = os.path.expanduser(self.executePath)
        os.chdir(theDir)
        self.runScript(self.executeScript)

        # ----------------------------------------------------------------------
        # Before running the application specific commands we need to create a
        # directory that is similar to the setup in a docker container so that
        # the {web-commands.sh can reference the same directory structure
        # ----------------------------------------------------------------------
        standardAppUtilsDir = "/app-utils/conf"
        if not os.path.exists(standardAppUtilsDir):
            cmdToRun = "sudo mkdir /app-utils ; sudo chmod 755 /app-utils"
            self.runScript(cmdToRun)

        # and no make a symbolic link from the customer app utils to his new
        # dir
        custAppUtilsDir = os.path.expanduser(
            "~/" + self.appName + "/" + self.appName + "-utils/config/" +
            self.env)
        linkToRun = "sudo ln -s " + custAppUtilsDir + " " + standardAppUtilsDir
        self.runScript(linkToRun)

        # -------------------------------------------------------------------------
        # run the appliction specific web_commands.sh
        # -------------------------------------------------------------------------
        webCmdToRun = standardAppUtilsDir + "/web-commands.sh"
        if os.path.isfile(webCmdToRun):
            os.chdir(standardAppUtilsDir)
            cmdToRun = "sudo ./web-commands.sh " + self.suffix
            self.runScript(cmdToRun)

        # and move back to the original directory
        os.chdir(currentDir)


def checkArgs():
    """Check the command line arguments."""
    parser = argparse.ArgumentParser(
        description=('comment'))
    parser.parse_args()


def main(argv):
    """Main code goes here."""
    checkArgs()


if __name__ == "__main__":
    main(sys.argv[1:])

# vim: tabstop=4 expandtab shiftwidth=4 softtabstop=4
