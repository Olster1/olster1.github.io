#define DEBUG_TIME_BLOCK()
#include "easy_types.h"
#include "easy_array.h"
#include "easy_unicode.h"
#include "easy_string.h"
#include "easy_files.h"

typedef struct {
	InfiniteAlloc contentsToWrite;
} FileState;

static initFileState(FileState *state) {
	state->contentsToWrite = initInfinteAlloc(u8);
}

static void outputFile(FileState *state, char *filename) {
	FILE *file = fopen(filename, "wb");

	size_t sizeWritten = fwrite(state->contentsToWrite.memory, 1, state->contentsToWrite.count, file);

	fclose(file);
}

static u8 *openFileNullTerminate(char *filename) {
	FILE *file = fopen(filename, "rb");

	if(fseek(file, 0, SEEK_END) != 0) {
		assert(false);
	}

	size_t sizeOfFile = ftell(file);

	if(fseek(file, 0, SEEK_SET) != 0) {
		assert(false);
	}	

	//NOTE(ollie): plus one for null terminator
	u8 * result = (u8 *)malloc(sizeof(u8)*(sizeOfFile + 1)); 

	size_t sizeRead = fread(result, 1, sizeOfFile, file);
	if(sizeRead != sizeOfFile) {
		assert(false);
	}

	result[sizeOfFile] = '\0';

	fclose(file);

	return result;

}

static void writeLineBreak(FileState *state, int count) {
	char *text = "<br>";
	for(int i = 0; i < count; ++i) {
		u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
		addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
	}
	
}

static void writeHeader(FileState *state) {
	char *text = "<!DOCTYPE html>\
	<html lang=\"en\">\
		<head>\
		  <title>Oliver Marsh</title>\
		  <meta charset=\"utf-8\">\
		  <meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">\
		  <link rel=\"stylesheet\" href=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/css/bootstrap.min.css\">\
		  <link href=\"https://fonts.googleapis.com/css?family=Montserrat\" rel=\"stylesheet\">\
		  <script src=\"https://ajax.googleapis.com/ajax/libs/jquery/1.12.4/jquery.min.js\"></script>\
		  <script src=\"https://maxcdn.bootstrapcdn.com/bootstrap/3.3.7/js/bootstrap.min.js\"></script>\
		  <link rel=\"stylesheet\" type=\"text/css\" href=\"style.css\">\
		</head>";

		u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
		addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}

static void writeNavBar(FileState *state) {
	char *text = "<nav class=\"navbar navbar-default\" style=\"background-color: white; color: #f5f6f7;\">\
	  <div class=\"container\">\
	    <div class=\"navbar-header\">\
	      <button type=\"button\" class=\"navbar-toggle\" data-toggle=\"collapse\" data-target=\"#myNavbar\">\
	        <span class=\"icon-bar\"></span>\
	        <span class=\"icon-bar\"></span>\
	        <span class=\"icon-bar\"></span>\
	      </button>\
	      <a class=\"navbar-brand\" href=\"./index.html#\">Oliver Marsh</a>\
	    </div>\
	    <div class=\"collapse navbar-collapse\" id=\"myNavbar\">\
	      <ul class=\"nav navbar-nav navbar-right\">\
	      	<li><a href=\"./apps.html\">Apps</a></li>\
	      	<li><a href=\"./projects.html\">Projects</a></li>\
	      </ul>\
	    </div>\
	  </div>\
	</nav>\
	<body>\
	<div class=\"container\">";

	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);

}

static void startParagraph(FileState *state) {
	char *text = "<p>\n"; 
	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}

static void endParagraph(FileState *state) {
	char *text = "</p>\n"; 
	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}


#define writeText(state, text) writeText_(state, text, easyString_getSizeInBytes_utf8(text))
static void writeText_(FileState *state, char *text, u32 sizeInBytes) {
	
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}

static u32 getBytesUntilNewLine(u8 *at) {
	u32 result = 0;
	while(*at && !(at[0] == '\n' || at[0] == '\r')) {
		at++;
		result++; 
	}

	return result;
}

#define writeParagraph(state, text) writeParagraph_(state, text, easyString_getSizeInBytes_utf8(text))
#define writeParagraph_withSize(state, text) writeParagraph_(state, text, getBytesUntilNewLine((u8 *)text))
static u32 writeParagraph_(FileState *state, char *text, u32 sizeInBytes) {
	startParagraph(state);
	
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);

	endParagraph(state);
	return sizeInBytes;
}


#define writeH1(state, text) writeH1_(state, text, easyString_getSizeInBytes_utf8(text))
#define writeH1_withSize(state, text) writeH1_(state, text, getBytesUntilNewLine((u8 *)text))
static u32 writeH1_(FileState *state, char *title, u32 sizeInBytes) {
	writeText(state, "<h1>");
	writeText_(state, title, sizeInBytes);
	writeText(state, "</h1>");
	return sizeInBytes;
}

#define writeH2(state, text) writeH2_(state, text, easyString_getSizeInBytes_utf8(text))
#define writeH2_withSize(state, text) writeH2_(state, text, getBytesUntilNewLine((u8 *)text))
static u32 writeH2_(FileState *state, char *title, u32 sizeInBytes) {
	writeText(state, "<h2>");
	writeText_(state, title, sizeInBytes);
	writeText(state, "</h2>");
	return sizeInBytes;
}

#define writeH3(state, text) writeH3_(state, text, easyString_getSizeInBytes_utf8(text))
#define writeH3_withSize(state, text) writeH3_(state, text, getBytesUntilNewLine((u8 *)text))
static u32 writeH3_(FileState *state, char *title, u32 sizeInBytes) {
	writeText(state, "<h3>");
	writeText_(state, title, sizeInBytes);
	writeText(state, "</h3>");
	return sizeInBytes;
}

#define writeH4(state, text) writeH4_(state, text, easyString_getSizeInBytes_utf8(text))
#define writeH4_withSize(state, text) writeH4_(state, text, getBytesUntilNewLine((u8 *)text))
static u32 writeH4_(FileState *state, char *title, u32 sizeInBytes) {
	writeText(state, "<h4>");
	writeText_(state, title, sizeInBytes);
	writeText(state, "</h4>");
	return sizeInBytes;
}

static void writeSeperator(FileState *state) {
	writeText(state, "<hr>");
}

static void startInfoCard(FileState *state) {
	char *text = "<div class=\"row\">\n<div class=\"col-sm-10\">\n<div class=\"info-card\">\n";

	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}

static void endInfoCard(FileState *state) {
	char *text = "</div>\n</div>\n</div>\n";
	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);
}
static void writeFooter(FileState *state) {
	char *text = "</div></body></html>";
	u32 sizeInBytes = easyString_getSizeInBytes_utf8(text);
	addElementInifinteAllocWithCount_(&state->contentsToWrite, text, sizeInBytes);

}

static void eatWhiteSpace(u8 **at_) {
	u8 *at = *at_;
	while(*at && (at[0] == '\n' || at[0] == '\r' || at[0] == ' ')) {
		at++;
	}

	(*at_) = at;
}

int main(int argc, char **args) {
	if(argc >= 3) {

		char *exts[] = { "md" };
		FileNameOfType filesToConvert = getDirectoryFilesOfType(args[1], exts, 1);
		printf("%s\n", args[1]);
		for(int fileIndex = 0; fileIndex < filesToConvert.count; ++fileIndex) {

			FileState state = {0};
			initFileState(&state);

			writeHeader(&state);
			writeNavBar(&state);

			bool inCard = false;

			printf("%s\n", filesToConvert.names[fileIndex]);
			
			u8 *result = openFileNullTerminate(filesToConvert.names[fileIndex]);
			u8 *at = result;
			while(*at) {
				// printf("%s\n", at);
				if(false) {
					//NOTE(ollie): Just to make it look nicer with all else ifs

				} else if(stringsMatchNullN("#CARD", at, 5)) { //NOTE(ollie): paragraph
					at += 5;
					if(inCard) {
						endInfoCard(&state);
					}
					inCard = true;
					startInfoCard(&state);
					//NOTE(ollie): Eat all white space, so don't put in any new lines
					eatWhiteSpace(&at);
				} else if(stringsMatchNullN("#HR", at, 3)) { //NOTE(ollie): paragraph
					at += 3;
					writeSeperator(&state);
					eatWhiteSpace(&at);
				} else if(stringsMatchNullN("#BR", at, 3)) { //NOTE(ollie): paragraph
					at += 3;
					writeLineBreak(&state, 1);
					eatWhiteSpace(&at);
				} else if(stringsMatchNullN("####", at, 4)) { //NOTE(ollie): H3
					at += 4;
					at += writeH4_withSize(&state, at);
				} else if(stringsMatchNullN("###", at, 3)) { //NOTE(ollie): H3
					at += 3;
					at += writeH3_withSize(&state, at);
				} else if(stringsMatchNullN("#TITLE", at, 6)) { //NOTE(ollie): H1
					at += 6;
					if(at[0] == ' ') {
						at++;
					}
					at += writeH1_withSize(&state, at);
					eatWhiteSpace(&at);
				} else if(at[0]== '\n' || at[0]== '\r') { //NOTE(ollie): H1
					// writeLineBreak(&state, 1);
					if(at[0] == '\r' && at[1] == '\n') {
						at += 2;
					} else {
						at++;	
					}
				} else if(stringsMatchNullN("##", at, 2)) { //NOTE(ollie): H2
					at += 2;
					at += writeH2_withSize(&state, at);
					eatWhiteSpace(&at);
				} else if(stringsMatchNullN("#", at, 1)) { //NOTE(ollie): paragraph
					at++;
					at += writeParagraph_withSize(&state, at);
				} else {
					at++;
				}
			}

			if(inCard) {
				endInfoCard(&state);
				inCard = false;
			}

			writeLineBreak(&state, 2);
			writeFooter(&state);

			char *shortName = getShortName(filesToConvert.names[fileIndex]);
			printf("%s\n", shortName);
			char *outputFileNameA = concat(shortName, ".html");
			char *outputFileNameB = concat(args[2], outputFileNameA);
			printf("%s\n", outputFileNameB);
			outputFile(&state, outputFileNameB);	

			//NOTE(ollie): Free all memory for this file
			free(outputFileNameA);
			free(outputFileNameB);
			free(result);
			free(filesToConvert.names[fileIndex]);
			free(shortName);
		}
				
	} else {
		printf("%s\n", "You need to pass an input file & an output file name");
	}
	
	
	return 0;
}