/* This file is linked into the runtime for the sole purpose
 * of testing FFI code. */
#include <stdio.h>

void ffi_test_0(void)
{
	printf("ffi_test_0()\n");
}

int ffi_test_1(void)
{
	printf("ffi_test_1()\n");
	return 3;
}

int ffi_test_2(int x, int y)
{
	printf("ffi_test_2(%d,%d)\n",x,y);
	return x + y;
}

int ffi_test_3(int x, int y, int z, int t)
{
	printf("ffi_test_3(%d,%d,%d,%d)\n",x,y,z,t);
	return x + y + z * t;
}

float ffi_test_4(void)
{
	printf("ffi_test_4()\n");
	return 1.5;
}

double ffi_test_5(void)
{
	printf("ffi_test_5()\n");
	return 1.5;
}

double ffi_test_6(float x, float y)
{
	printf("ffi_test_6(%f,%f)\n",x,y);
	return x * y;
}

double ffi_test_7(void)
{
	return 1.5;
}
