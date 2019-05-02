# resource-list-generator.py
# classaction-air-app
# 2019-05-02

# This Python 2 script parses the ClassAction XML files and creates lists
#  of each type of resource. Specifically, it creates the following files:
#  questions.csv, animations.csv, images.csv, outlines.csv, and tables.csv.
#  The CSV files can be imported into any spreadsheet program.
# Resources may appear multiple times in a list since a resource may be
#  used by multiple modules.


# The base directory for the ClassAction files, relative to this script.
classActionBaseDir = "../files"

# The name of the modules list XML file, which should be in the base directory.
modulesListFilename = "moduleslist.xml"


import os
#import sys
from xml.dom import minidom, Node


def getModuleResourcesInCVSForm(moduleLongName, moduleXML, type):
	# This function adds the resources of a particular type from a module.
	#   moduleLongName: a string
	#   moduleXML: the XML for the module
	#   cvsStr: the string to append the resource information to
	#   type: one of "questions", "animations", etc.

	if type == "questions":
		elementsList = moduleXML.getElementsByTagName("Question")
	elif type == "animations":
		elementsList = moduleXML.getElementsByTagName("Animation")
	elif type == "images":
		elementsList = moduleXML.getElementsByTagName("Image")
	elif type == "outlines":
		elementsList = moduleXML.getElementsByTagName("Outline")
	elif type == "tables":
		elementsList = moduleXML.getElementsByTagName("Table")
	else:
		raise ValueError("Invalid type.")

	cvsStr = ""
	
	for element in elementsList:
		id = element.firstChild.nodeValue
		resourceNode = resources[type][id]
		name = resourceNode.getElementsByTagName("Name")[0].firstChild.nodeValue
		cvsStr += "\"" + moduleLongName + "\", \"" + name + "\", \"" + resourceNode.getElementsByTagName("File")[0].firstChild.nodeValue + "\"\n"

	return cvsStr


def writeListFile(cvsStr, type):
	listFile = open(type + ".csv", "w")
	listFile.write(cvsStr)
	listFile.close()


def generateLists():
	# This function generates and writes the lists.
	# It assumes that the current working directory when called is the
	#  ClassAction base path, and it sets the current working directory
	#  back to the stored original value before writing the CVS files.  

	questionsCVS = "Module, ID, Path\n"
	animationsCVS = "Module, ID, Path\n"
	imagesCVS = "Module, ID, Path\n"
	outlinesCVS = "Module, ID, Path\n"
	tablesCVS = "Module, ID, Path\n"

	modulesXML = minidom.parse(modulesListFilename)

	for module in modulesXML.getElementsByTagName("module"):
		moduleFileName = module.firstChild.nodeValue
		moduleShortName = moduleFileName[0:moduleFileName.rfind(".")]
		moduleXML = minidom.parse(moduleFileName)
		moduleLongName = moduleXML.getElementsByTagName("ModuleSpecification")[0].attributes["id"].nodeValue

		questionsCVS += getModuleResourcesInCVSForm(moduleLongName, moduleXML, "questions")
		animationsCVS += getModuleResourcesInCVSForm(moduleLongName, moduleXML, "animations")
		imagesCVS += getModuleResourcesInCVSForm(moduleLongName, moduleXML, "images")
		outlinesCVS += getModuleResourcesInCVSForm(moduleLongName, moduleXML, "outlines")
		tablesCVS += getModuleResourcesInCVSForm(moduleLongName, moduleXML, "tables")

	os.chdir(cwdAtStart)

	writeListFile(questionsCVS, "questions")
	writeListFile(animationsCVS, "animations")
	writeListFile(imagesCVS, "images")
	writeListFile(outlinesCVS, "outlines")
	writeListFile(tablesCVS, "tables")



cwdAtStart = os.getcwd()

os.chdir(classActionBaseDir)

# resources will be an associative array of resources sorted by type. It will
#  contain five objects, one for each type of resource. In turn, each resource
#  type object is an associative array containing the XML definition nodes for
#  each resource, indexed by the resource's id.
# E.g: resources["questions"]["ca_intro_scale"] -> XML node defining that question
resources = {}

questionsXML = minidom.parse("questions/questions.xml")
questionsTable = {}
for question in questionsXML.getElementsByTagName("Question"):
	questionsTable[question.attributes["id"].nodeValue] = question
resources["questions"] = questionsTable

animationsXML = minidom.parse("animations/animations.xml")
animationsTable = {}
for animation in animationsXML.getElementsByTagName("Animation"):
	animationsTable[animation.attributes["id"].nodeValue] = animation
resources["animations"] = animationsTable

imagesXML = minidom.parse("images/images.xml")
imagesTable = {}
for image in imagesXML.getElementsByTagName("Image"):
	imagesTable[image.attributes["id"].nodeValue] = image
resources["images"] = imagesTable

outlinesXML = minidom.parse("outlines/outlines.xml")
outlinesTable = {}
for outline in outlinesXML.getElementsByTagName("Outline"):
	outlinesTable[outline.attributes["id"].nodeValue] = outline
resources["outlines"] = outlinesTable

tablesXML = minidom.parse("tables/tables.xml")
tablesTable = {}
for table in tablesXML.getElementsByTagName("Table"):
	tablesTable[table.attributes["id"].nodeValue] = table
resources["tables"] = tablesTable


generateLists()


