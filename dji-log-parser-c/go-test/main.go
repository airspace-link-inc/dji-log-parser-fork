package main

/*
#cgo LDFLAGS: -L../../target/debug -ldji_log_parser_c
#cgo CFLAGS: -I../include
#include "dji-log-parser-c.h"
#include <stdlib.h>
*/
import "C"

import (
	"flag"
	"fmt"
	"io"
	"log"
	"os"
	"unsafe"
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
	log.Println("Input file size: ", size)

	cApiKey := C.CString(*apiKey)
	defer C.free(unsafe.Pointer(cApiKey))

	rawOutput := C.parse_from_bytes((*C.uchar)(unsafe.Pointer(cData)), size, cApiKey)
	if rawOutput == nil {
		errPtr := C.get_error()
		errStr := C.GoString(errPtr)
		C.c_api_free_string(errPtr)

		log.Fatalln("Failed to parse file: ", errStr)
	}
	defer C.c_api_free_string(rawOutput)

	output := C.GoString(rawOutput)

	fmt.Println(output)
}
