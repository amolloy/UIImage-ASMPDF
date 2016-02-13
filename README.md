UIImage-ASMPDF
==============

A category on UIImage for loading PDFs, inspired by UIImage-PDF. UIImage-ASMPDF functions in much the same way as UIImage-PDF, but simplifies the implementation by removing the need for an extra UIView. UIImage-ASMPDF also allows you to specify a region within the PDF to render into an image, rather than always rendering the entire page. 

### CocoaPods 
`pod 'UIImage-ASMPDF'`

## Usage

```objective-c
NSURL* imageURL = ...; // URL pointing to a PDF
UIImage* image = [UIImage imageWithPDFatURL:imageURL destinationSize:CGSizeMake(320, 415)];
```

This will return an image that is a rendering of the PDF's first page. The image's size will match the destinationSize. The image will be opaque, and have its scale set to match [UIScreen mainScreen].scale. Other methods exist to give you control over those settings.

You can also specify a rectangular region within the PDF's first page to render, rather than the entire image. 

```objective-c
CGRect cropRect = CGRectMake(0, 0, 96, 96);
UIImage* croppedImage = [UIImage imageWithPDFatURL:imageURL destinationSize:CGSizeMake(300, 300) cropRect:cropRect];
```

The cropping rect should be specified in points. 

UIImage-ASMPDF supports caching the rendered images to memory, disk, or both. To request caching:

```objective-c
	[UIImage setASMPDFCacheType:ASMPDFNoCache]; // No cache (the default)
	[UIImage setASMPDFCacheType:ASMPDFMemoryCache]; // Cache to memory
	[UIImage setASMPDFCacheType:ASMPDFDiskCache]; // Cache to disk
	[UIImage setASMPDFCacheType:ASMPDFDiskCache | ASMPDFMemoryCache]; //Cache to memory and disk, favoring memory.
```

This should be called early on, such as in your app delegate's application:didFinishLaunchingWithOptions: method.

The memory cache uses NSCache and so should be purged if your app receives a memory warning.

The disk cache stores the rendered images as PNGs within your app's NSCachesDirectory, meaning the device may clear the cache to free disk space without warning.

If you specify to use both memory and disk caches, the memory cache will be checked first, then the disk. Both caches are updated simultaneously.

## Limitations

UIImage-ASMPDF currently only supports rendering the first page of a multipage PDF. Support for multiple pages ought to be easy enough to support, but I don't currently have use of it. Pull requests always welcome!
