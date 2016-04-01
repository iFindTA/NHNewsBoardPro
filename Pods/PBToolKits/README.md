# PBToolKits
### 开发过程中经常用到的Utils for iOS Developers
#### 如果后续文件过大再考虑分文件处理

##### Usage:
通过Pod搜索：打开终端执行**$ Pod Search PBToolKits**

##### Info Description:
```
NSString:
/**
 *	@brief	Judging method
 *
 *	@return	whether the string is empty
 */
- (BOOL)pb_isEmpty;

/**
 *	@brief	Judging method
 *
 *	@return	whether only contain numbers
 */
- (BOOL)pb_isOnlyNumbers;

/**
 *	@brief	Judging method
 *
 *	@return	wheter only contain letters
 */
- (BOOL)pb_isOnlyLetters;

/**
 *	@brief	Judging method
 *
 *	@return	whether only contain number or letter
 */
- (BOOL)pb_isNumberOrLetter;

/**
 *	@brief	caculate string's size
 *
 *	@param 	font 	string's font
 *	@param 	width 	string's width
 *
 *	@return	the adjust size of string
 */
- (CGSize)pb_sizeThatFitsaWithFont:(UIFont *)font width:(CGFloat)width;

```



```
UIImage:
/**
 *	@brief	Judging Method
 *
 *	@param 	image 	other image
 *
 *	@return	whether only the two image is equal
 */
- (BOOL)pb_isEqualTo:(UIImage *)image;


/**
 *	@brief	generate image
 *
 *	@param 	color 	the image's color
 *
 *	@return	the image from color
 */
+ (UIImage *)pb_imageWithColor:(UIColor *)color;

/**
 *	@brief	blur image
 *
 *	@param 	blurAmount 	blur level, default is 0.5
 *
 *	@return	the blured image
 */
- (UIImage *)pb_blurredImage:(CGFloat)level;

/**
 *	@brief	generate small image
 *
 *	@param 	bounds 	the destnation image's frame
 *
 *	@return	the cropped image
 */
- (UIImage *)pb_croppedBounds:(CGRect)bounds;

/**
 *	@brief	scale image
 *
 *	@param 	dstSize 	the destnation size
 *
 *	@return	the scaled image
 */
- (UIImage*)pb_scaleToSize:(CGSize)dstSize DEPRECATED_MSG_ATTRIBUTE("use pb_scaleToSize: keepAspect: method instead");

/**
 *	@brief	scale image
 *
 *	@param 	dstSize 	the destnation size
 *	@param 	keep 	whether keep image's width/height scale info
 *
 *	@return	the scaled image
 */
- (UIImage*)pb_scaleToSize:(CGSize)dstSize keepAspect:(BOOL)keep;

/**
 *	@brief	generate round image
 *
 *	@return	the round image
 */
- (UIImage *)pb_roundImage;

/**
 *	@brief	generate round corner image
 *
 *	@param 	radius 	the round corner radius
 *
 *	@return	the round corner image
 */
- (UIImage *)pb_roundCornerWithRadius:(int)radius;

/**
 *	@brief	generate round corner image
 *
 *	@param 	radius 	the round corner redius
 *	@param 	bWidth 	the border width
 *	@param 	bColor 	the border color default is white
 *
 *	@return	the round corner image
 */
- (UIImage *)pb_roundCornerWithRadius:(int)radius withBorderWidth:(int)bWidth withBorderColor:(UIColor *)bColor;

/**
 *	@brief	generate dark image
 *
 *	@param 	color 	dark color
 *	@param 	level 	dark level
 *
 *	@return	the dark image
 */
- (UIImage *)pb_darkColor:(UIColor *)color lightLevel:(CGFloat)level;
```