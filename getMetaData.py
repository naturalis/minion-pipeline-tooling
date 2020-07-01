#!/usr/bin/env python3

# Copyright (C) 2018 Jasper Boom

# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU Affero General Public License version 3 as
# published by the Free Software Foundation.

# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
# GNU Affero General Public License for more details.

# You should have received a copy of the GNU Affero General Public License
# along with this program. If not, see <https://www.gnu.org/licenses/>.

# Prequisites:
# - sudo apt-get install python
# - sudo apt-get install python-pip
# - sudo pip install pandas

# Galaxy prequisites:
# - sudo ln -s /path/to/folder/galaxy-tool-metadata-harvester/getMetaData.py 
#              /usr/local/bin/getMetaData.py

# Imports
import os
import sys
import argparse
import re
import math
import itertools
import pandas as pd
import subprocess as sp
import requests
import csv

# The getDownload function.
# This function downloads a image based on the getPictureUrl function output.
# The name of such a image consists of [OTU_ID]-[species_name]-[database].
def getDownload(strUrl):
    rafDownload = sp.Popen(["wget", "-O", strUrl[1], strUrl[0]], stdout=sp.PIPE,
                           stderr=sp.PIPE)
    strOut, strError = rafDownload.communicate()


# The getPictureUrl function.
# This function calls a database api [Naturalis/BOLD/ALA] and searches through
# the output for a specific string. This string differs depending on what
# database is being searched. After finding this string, the image link is
# isolated. In the case of the BOLD database, a small edit needs to be applied
# in order to create a correct http format. This http link, along with a species
# name linked by _ is returned as output.
# Edit by Heleen: removed sp.Popen function and replaced it with a request.get

def getPictureUrl(strCommand, strStart, strOutputPath, strOtu, lstSpecies,
                  strDatabase):
    r = requests.get(strCommand)
    strOut = r.text
    try:
        intUrlStart = re.search(strStart, strOut).end()
        intUrlEnd = re.search('"', strOut[intUrlStart+3:]).start()
        strDownload = strOut[intUrlStart+3:][:intUrlEnd]
        strSpeciesName = "_".join(lstSpecies)
        strPictureFile = strOutputPath + strOtu + "-" + strSpeciesName + "-" +\
                         strDatabase + ".jpg"
        if strDatabase == "BOLD":
            strDownload = strDownload.replace("\\", "")
        else:
            pass
        return strDownload, strPictureFile
    except AttributeError:
        pass

# Added by Heleen: 
# getNaturalisApi function. Creates URL based on Naturlis api backbone and includes
# getPictureURL 
# function.
def getNaturalisApi(strSpeciesCommand, strOutputPath, strOtu, lstSpecies):
    strNaturalisCommand = "http://api.biodiversitydata.nl/v2/multi" +\
                          "media/query?identifications.scientific" +\
                          "Name.scientificNameGroup=" +\
                          strSpeciesCommand + "&_fields=service" +\
                          "AccessPoints"
    strNaturalisUrl = getPictureUrl(strNaturalisCommand, "accessUri",
                                    strOutputPath, strOtu, lstSpecies,
                                    "NATURALIS")

# The getBoldApi function.
# This function creates a api string with the provided name. This api string is
# based on the BOLD api backbone. The created api string is included in the call
# of the getPictureUrl function.
def getBoldApi(strSpeciesCommand, strOutputPath, strOtu, lstSpecies):
    strBoldCommand = "http://www.boldsystems.org/index.php/API_Public/" +\
                     "specimen?taxon=" + strSpeciesCommand + "&format=json"
    strBoldUrl = getPictureUrl(strBoldCommand, "image_file", strOutputPath,
                               strOtu, lstSpecies, "BOLD")
    return strBoldUrl

# The getAlaApi function.
# This function creates a api string with the provided name. This api string is
# based on the ALA api backbone. The created api string is included in the call
# of the getPictureUrl function.
def getAlaApi(strSpeciesCommand, strOutputPath, strOtu, lstSpecies):
    strAlaCommand = "http://bie.ala.org.au/ws/search.json?q=" +\
                    strSpeciesCommand + "&facets=imageAvailable"
    strAlaUrl = getPictureUrl(strAlaCommand, "imageUrl", strOutputPath,
                                strOtu, lstSpecies, "ALA")
    return strAlaUrl

# Added by Heleen: add to dict function
def updateDict (species, url, source, d):
    if species not in d:
        d[species] = [url, source]
    else:
        pass
    return d

# The getPicture function.
# This function loops through the species column and OTU column. Every species 
# is transformed into a format that is in database api's. 
# First the Bold database is called. If it produces no image or an empty file, the Ala 
# database is called. Finally, if this also does not produce an image or an empty file, 
# the Naturalis database is called. 
# No result after the Naturalis call, means no image is retrievable.
# Edit by Heleen: reduced to half the amount of code.
def getPicture(tblReadInput, strOutputPath, tblSpecies):
    URLdict = {}
    tblOtu = tblReadInput.ix[:,2]
    for strOtu, strSpecies in zip(tblOtu, tblSpecies):
        try:
            lstSpecies = strSpecies.split()
            strSpeciesCommand = "%20".join(lstSpecies).lower()
            # Try BOLD
            strBoldUrl = getBoldApi(strSpeciesCommand, strOutputPath, strOtu, lstSpecies)
            if strBoldUrl and strSpecies != 'Xanthichthys lineopunctatus':
                getDownload(strBoldUrl)
                if os.stat(strBoldUrl[1]).st_size == 0:
                    rafRemove = sp.call(["rm", strBoldUrl])
                else:
                    URLdict = updateDict (strSpecies, strBoldUrl[0], 'BOLD', URLdict)
            else:
            # Try ALA
                strAlaUrl = getAlaApi(strSpeciesCommand,
                                      strOutputPath, strOtu,
                                      lstSpecies)
                if strAlaUrl:
                    getDownload(strAlaUrl)
                    if os.stat(strAlaUrl[1]).st_size == 0:
                        rafRemove = sp.call(["rm", strAlaUrl])
                    else:
                        URLdict = updateDict (strSpecies, strAlaUrl[0], 'ALA', URLdict)
                else:
                    # Try Naturalis
                    strNaturalisUrl = getNaturalisApi(strSpeciesCommand, strOutputPath,
                                                      strOtu, lstSpecies)
                    if strNaturalisUrl:
                        getDownload(strNaturalisUrl)
                        if os.stat(strNaturalisUrl[1]).st_size == 0:
                            rafRemove = sp.call(["rm", strNaturalisUrl])
                        else:
                            URLdict = updateDict (strSpecies, strNaturalisUrl[0], 
                                                  'Naturalis', URLdict)
        except AttributeError:
            pass
    URLdf = pd.DataFrame.from_dict(URLdict, orient='index', columns=['URL', 'source'])
    URLdf.index.name = 'species'
    URLdf.to_csv('URLdf.txt', sep="\t", quoting=csv.QUOTE_NONE)
    return URLdict

# The getOccurrenceStatus function.
# This function loops through the names column generated by the
# getNameColumn function. Every name is transformed into a correct format in
# order to support the Naturalis bioportal api. The Naturalis bioportal api is
# called. The word "occurrenceStatusVerbatim" is searched for in the output of
# the api. The value after the word occurrenceStatusVerbatim is isolated and
# this value is added to the list lstStatus. If no value can be found, a empty
# string is added to the list lstStatus. After every species name is processed,
# the list lstStatus is added to the input file as a new column and outputted as
# a new file.
# Edit by Heleen: removed sp.open function and replaced with request.get
def getOccurrenceStatus(tblReadInput, strOutputPath, tblSpecies):
    dicOccurrence = {"0": "Reported", "0a": "Reported correctly, to be refined",
                     "1": "Indigenous (undetermined)",
                     "1a": "Indigenous: native species",
                     "1b": "Indigenous: incidental/periodical species",
                     "2": "Introduced (undetermined)",
                     "2a": "Introduced: at least 100 years independent survival",
                     "2b": "Introduced: 10-100 years independent survival",
                     "2c": "Introduced: less than 10 years independent survival",
                     "2d": "Introduced: incidental import", "3a": "Data deficient",
                     "3b": "Incorrectly reported", "3c": "To be expected",
                     "3d": "Incorrectly used name (auct.)", "4": "Miscellaneous"}
    lstStatus = []
    for strRow in tblSpecies:
        try:
            lstSpecies = strRow.split()
            strSpeciesCommand = "%20".join(lstSpecies).lower()
            strCommand = "http://api.biodiversitydata.nl/v2/taxon/query?" +\
                         "acceptedName.scientificNameGroup=" +\
                         strSpeciesCommand +\
                         "&_fields=occurrenceStatusVerbatim"
            r = requests.get(strCommand)
            strOut = r.text
            intOccurrenceStart = re.search("occurrenceStatusVerbatim", 
                                           strOut).end()
            strOccurrence = strOut[intOccurrenceStart+3:intOccurrenceStart+5]
            strOccurrenceTotal = strOccurrence.strip(" ") + " " +\
                                 dicOccurrence[str(strOccurrence)]
            lstStatus.append(strOccurrenceTotal)
        except AttributeError:
            lstStatus.append("")
    tblReadInput["OccurrenceStatus"] = lstStatus
    strOutputPath = strOutputPath + "flNewOutput.tabular"
    tblReadInput.to_csv(strOutputPath, sep="\t", encoding="utf-8", index=False)


# The getNameColumn function.
# This function isolates a list of names used for the metadata processes. When
# processing a OTU file with standard BLAST identifications the names are
# isolated based on the taxonomy column at the end of a OTU file. Species names
# are extracted from the taxonomy column. When processing a OTU file with a LCA
# process file, the names are extracted from the lowest common ancestor column.
# When processing a accepted taxonomic name file, the names are extracted from
# the third column, but if a row is empty, the name in the second column is
# used. When processing a BLAST file, the names are isolated from the taxonomy
# column and extracted per row. Depending on what type of meta data the user
# wants, the species column is send to the correct functions.
# Edit by Heleen: removed formatting option
def getNameColumn(flInput, flOutput, strProcess):
    tblReadInput = pd.read_csv(flInput)
    lstOtuNames = tblReadInput.ix[:,1]
    lstSpecies = tblReadInput.iloc[:,3]
    if strProcess == "occurrences":
        getOccurrenceStatus(tblReadInput, flOutput, lstSpecies)
    elif strProcess == "pictures":
        getPicture(tblReadInput, flOutput, lstSpecies)
    else:
        pass



# The argvs function.
# Edit by Heleen: removed formatting option.
def parseArgvs():
    parser = argparse.ArgumentParser(description="Use a python script to\
                                                  utilize the Naturalis, BOLD\
                                                  and ALA api's to collect\
                                                  meta data.")
    parser.add_argument("-v", action="version", version="%(prog)s [0.1.0]")
    parser.add_argument("-i", action="store", dest="fisInput",
                        help="The location of the input file(s)")
    parser.add_argument("-o", action="store", dest="fosOutput",
                        help="The location of the output file(s)")
    parser.add_argument("-p", action="store", dest="disProcess",
                        help="The metadata process type [occurrences/pictures]")
    argvs = parser.parse_args()
    return argvs

# The main function.
def main():
    argvs = parseArgvs()
    getNameColumn(argvs.fisInput, argvs.fosOutput, argvs.disProcess)

if __name__ == "__main__":
    main()

# Additional information:
# =======================
#
# Sample names can not start with a "#".
# All columns in a OTU table should have a header starting with "#".
