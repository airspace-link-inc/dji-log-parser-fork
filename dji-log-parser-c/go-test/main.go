package main

/*
#cgo LDFLAGS: -L${SRCDIR}/../../target/debug -ldji_log_parser
#cgo CFLAGS: -I${SRCDIR}/../include
#include "dji-log-parser-c.h"
#include <stdlib.h>
*/

import "C"

import (
	"flag"
	"io"
	"log"
	"os"
)

var (
	inputPath = flag.String("input_path", "", "Specifies the input DJI log file to parse.")
	apiKey    = flag.String("api_key", "", "DJI API key use to decrypt logs.")
)

func main() {
	flag.Parse()

	file, err := os.Open(*inputPath)
	if err != nil {
		log.Fatalf("failed to open file '%s': %v", *inputPath, err)
	}
	defer file.Close()

	buf, err := io.ReadAll(file)
	if err != nil {
		log.Fatalf("failed to read contents of file to buffer: %v", err)
	}

	cData := C.CBytes(buf)
	defer C.free(cData)

	size := C.size_t(len(buf))
	log.Println("Input file size: %d", size)

	cApiKey := C.CString(*apiKey)
	defer C.free(cApiKey)

	rawOutput := C.parse_from_bytes()

}
