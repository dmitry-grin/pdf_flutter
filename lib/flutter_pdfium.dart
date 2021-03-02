
library flutter_pdfium;

import 'dart:ffi' as ffi;
import 'dart:io';

import 'package:flutter_pdfium/utils/functions.dart';


export 'package:flutter_pdfium/utils/functions.dart';
export 'package:flutter_pdfium/utils/structs.dart';

void loadDylib(String path) {
  var dylib = Platform.isIOS ? ffi.DynamicLibrary.process() : ffi.DynamicLibrary.open(path);

  fInitLibraryWithConfig =
      dylib.lookupFunction<FPDF_InitLibraryWithConfig, InitLibraryWithConfig>(
        "FPDF_InitLibraryWithConfig",
      );
  fDestroyLibrary = dylib.lookupFunction<FPDF_DestroyLibrary, DestroyLibrary>(
    "FPDF_DestroyLibrary",
  );
  fLoadDocument = dylib.lookupFunction<FPDF_LoadDocument, FPDF_LoadDocument>(
    "FPDF_LoadDocument",
  );
  fGetLastError = dylib.lookupFunction<FPDF_GetLastError, GetLastError>(
    "FPDF_GetLastError",
  );
  fCloseDocument = dylib.lookupFunction<FPDF_CloseDocument, CloseDocument>(
    "FPDF_CloseDocument",
  );
  fGetPageCount = dylib.lookupFunction<FPDF_GetPageCount, GetPageCount>(
    "FPDF_GetPageCount",
  );
  fLoadPage = dylib.lookupFunction<FPDF_LoadPage, LoadPage>(
    "FPDF_LoadPage",
  );
  fBitmapCreate = dylib.lookupFunction<FPDFBitmap_Create, BitmapCreate>(
    "FPDFBitmap_Create",
  );
  fRenderPageBitmap =
      dylib.lookupFunction<FPDF_RenderPageBitmap, RenderPageBitmap>(
        "FPDF_RenderPageBitmap",
      );
  fGetPageHeight = dylib.lookupFunction<FPDF_GetPageHeight, GetPageHeight>(
    "FPDF_GetPageHeight",
  );
  fGetPageWidth = dylib.lookupFunction<FPDF_GetPageWidth, GetPageWidth>(
    "FPDF_GetPageWidth",
  );
  fBitmapFillRect = dylib.lookupFunction<FPDFBitmap_FillRect, BitmapFillRect>(
    "FPDFBitmap_FillRect",
  );
  fBitmapGetBuffer =
      dylib.lookupFunction<FPDFBitmap_GetBuffer, BitmapGetBuffer>(
        "FPDFBitmap_GetBuffer",
      );
}