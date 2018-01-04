// 311130777 Raz Shenkman

#include "stdio.h"
#include "string.h"
#define BYTE 8
// enum for the operating systems.
enum opSystem {
    Unix, Mac, Win
};


/**
 * This function checks if the inputted text is big endian or little endian by check the first 2 bytes, if it's
 * 0xfeff it's little endian and if it's 0xfffe it's big endian.
 * @param input first 2 bytes of the file.
 * @return if the file is big endian.
 */
int findIfBigEndian(short int input) {
    if (input == (short int) 0xfffe) {
        return 1;
    } else {
        return 0;
    }
}

/**
 * This is the function for task 1, simply open the source file and a new destination file and copy the source file
 * to the destination file in 2 byte chunks.
 * @param src sources file name.
 * @param dst destinations file name.
 * @return void.
 */
void copyTxt(char *src, char *dst) {
    // check the destinations file name format
    int validDst = 0, i = 0;
    size_t len = strlen(dst);
    for (i; i < len; i++) {
        if (dst[i] == '.') {
            validDst = 1;
        }
    }
    if (!validDst) {
        // The destination file name is not valid
        return;
    }
    FILE *pS = fopen(src, "rb");

    short int buffer = 0;
    size_t twoBytesObject = 1;
    if (pS != NULL) {
        // only open a destination file if the source is valid.
        FILE *pT = fopen(dst, "wb");
        // copy the file in 2 bytes size chunks.
        while (0 < (twoBytesObject = fread(&buffer, sizeof(buffer), twoBytesObject, pS))) {
            fwrite(&buffer, sizeof(buffer), twoBytesObject, pT);
        }
        fclose(pT);
    } else {
        // The source file doesn't exist
        return;
    }
    fclose(pS);
}

/**
 * This function swaps 2 bytes in a short int and writes it into a file.
 * @param buffer - short int object to swap it's bytes.
 * @param dst destination to writes the bytes to.
 * @param twoBytesObject how many objects to write into the file.
 * @param switchBool if a switch is needed.
 */
void writeToFileAndMaybeSwap(short int *buffer, FILE *dst, size_t twoBytesObject, int switchBool) {
    short int firstHalf, secondHalf, finalBuffer, firstMask, secondMask;
    if (switchBool) {
        // switching the bytes using masks and bitwise operations.
        firstMask = (short int) 0xff00;
        secondMask = (short int) 0x00ff;
        firstHalf = (*buffer & firstMask) >> BYTE;
        secondHalf = (*buffer & secondMask) << BYTE;
        finalBuffer = secondHalf | firstHalf;
        fwrite(&finalBuffer, sizeof(finalBuffer), twoBytesObject, dst);
    } else {
        // no switch is needed
        fwrite(buffer, sizeof(finalBuffer), twoBytesObject, dst);
    }
}

/**
 * This is the function for task 2 and task 3, it transfer the files type from unix/mac/win to unix/mac/win by
 * changing it's end of line symbol. this function uses writeToFileAndMaybeSwap to write into the destination file
 * and swap bytes if needed.
 * @param src source file name.
 * @param dst destination file name.
 * @param from operation system enum type the source uses.
 * @param to operation system enum type the destination needs.
 * @param switchBool if a switch is needed.
 */
void copyTxtWithFlags(char *src, char *dst, enum opSystem from, enum opSystem to, int switchBool) {
    // check the destinations file name format
    int validDst = 0, i = 0;
    size_t len = strlen(dst);
    for (i; i < len; i++) {
        if (dst[i] == '.') {
            validDst = 1;
        }
    }
    if (!validDst) {
        // The destination file name is not valid\n");
        return;
    }
    FILE *pS = fopen(src, "rb");
    short int rSymbol, nSymbol, replaceTo = 0, replaceFrom = 0, buffer = 0, winBuffer = 0;
    size_t twoBytesObject = 1;
    int ifBigEndian = 0;
    if (pS != NULL) {
        // only if the source is valid open a destination file
        FILE* pT = fopen(dst, "wb");
        // first 2 bytes of txt shows if it's by little/big endian.
        fread(&buffer, sizeof(buffer), twoBytesObject, pS);
        ifBigEndian = findIfBigEndian(buffer);
        // set the /r and /n values according to the files type.
        if (ifBigEndian) {
            rSymbol = 0x0d00;
            nSymbol = 0x0a00;
            if (switchBool) {
                short int start = (short int) 0xfeff;
                fwrite(&start, sizeof(buffer), twoBytesObject, pT);
            }
        } else {
            rSymbol = 0x000d;
            nSymbol = 0x000a;
            if (switchBool) {
                short int start = (short int) 0xfffe;
                fwrite(&start, sizeof(buffer), twoBytesObject, pT);
            }
        }
        if (from == Unix) {
            replaceFrom = nSymbol;
        } else if (from == Mac) {
            replaceFrom = rSymbol;
        }
        if (to == Unix) {
            replaceTo = nSymbol;
        } else if (to == Mac) {
            replaceTo = rSymbol;
        }
        if (!switchBool) {
            fwrite(&buffer, sizeof(buffer), twoBytesObject, pT);
        }
        // if the files type doesn't involve win type.
        if (from != Win && to != Win) {
            while (0 < (twoBytesObject = fread(&buffer, sizeof(buffer), twoBytesObject, pS))) {
                if (buffer == replaceFrom) {
                    writeToFileAndMaybeSwap(&replaceTo, pT, twoBytesObject, switchBool);
                } else {
                    writeToFileAndMaybeSwap(&buffer, pT, twoBytesObject, switchBool);
                }
            }
        } else {
            // if the flags are from win to win
            if (to == Win && from == Win) {
                while (0 < (twoBytesObject = fread(&buffer, sizeof(buffer), twoBytesObject, pS))) {
                    writeToFileAndMaybeSwap(&buffer, pT, twoBytesObject, switchBool);
                }
                // if it's unix/mac to win
            } else if (to == Win) {
                while (0 < (twoBytesObject = fread(&buffer, sizeof(buffer), twoBytesObject, pS))) {
                    if (buffer == replaceFrom) {
                        writeToFileAndMaybeSwap(&rSymbol, pT, twoBytesObject, switchBool);
                        writeToFileAndMaybeSwap(&nSymbol, pT, twoBytesObject, switchBool);
                    } else {
                        writeToFileAndMaybeSwap(&buffer, pT, twoBytesObject, switchBool);
                    }
                }
                // if it's win to unix/mac
            } else {
                while (0 < (twoBytesObject = fread(&buffer, sizeof(buffer), twoBytesObject, pS))) {
                    if (buffer == rSymbol) {
                        if (0 < (twoBytesObject = fread(&winBuffer, sizeof(winBuffer), twoBytesObject, pS))) {
                            if (winBuffer == nSymbol) {
                                writeToFileAndMaybeSwap(&replaceTo, pT, twoBytesObject, switchBool);
                            } else {
                                writeToFileAndMaybeSwap(&rSymbol, pT, twoBytesObject, switchBool);
                                writeToFileAndMaybeSwap(&winBuffer, pT, twoBytesObject, switchBool);
                            }
                        } else {
                            writeToFileAndMaybeSwap(&rSymbol, pT, twoBytesObject, switchBool);
                        }
                    } else {
                        writeToFileAndMaybeSwap(&buffer, pT, twoBytesObject, switchBool);
                    }
                }
            }
            fclose(pT);
        }
    } else {
        // error reading the source file
        return;
    }
    fclose(pS);
}

/**
 * This function get the user inputted arguments and decides by using if conditions if the input is valid & how to
 * operate the copyTxtWithFlags function.
 * @param src source file name.
 * @param dst destination file name.
 * @param srcFlag operation system name the source uses.
 * @param dstFlag operation system name the destination needs.
 * @param switchBool if a switch is needed.
 */
void copyWithFlags(char *src, char *dst, char *srcFlag, char *dstFlag, int switchBool) {
    // from win type
    if (strcmp(srcFlag, "-win") == 0) {
        if (strcmp(dstFlag, "-unix") == 0) {
            copyTxtWithFlags(src, dst, Win, Unix, switchBool);
        } else if (strcmp(dstFlag, "-mac") == 0) {
            copyTxtWithFlags(src, dst, Win, Mac, switchBool);
        } else if (strcmp(dstFlag, "-win") == 0) {
            copyTxtWithFlags(src, dst, Win, Win, switchBool);
        } else {
            // Unrecognized target flag inputted
            return;
        }
        // from mac type
    } else if (strcmp(srcFlag, "-mac") == 0) {
        if (strcmp(dstFlag, "-unix") == 0) {
            copyTxtWithFlags(src, dst, Mac, Unix, switchBool);
        } else if (strcmp(dstFlag, "-win") == 0) {
            copyTxtWithFlags(src, dst, Mac, Win, switchBool);
        } else if (strcmp(dstFlag, "-mac") == 0) {
            copyTxtWithFlags(src, dst, Mac, Mac, switchBool);
        } else {
            // Unrecognized target flag inputted
            return;
        }
        // from unix type
    } else if (strcmp(srcFlag, "-unix") == 0) {
        if (strcmp(dstFlag, "-mac") == 0) {
            copyTxtWithFlags(src, dst, Unix, Mac, switchBool);
        } else if (strcmp(dstFlag, "-win") == 0) {
            copyTxtWithFlags(src, dst, Unix, Win, switchBool);
        } else if (strcmp(dstFlag, "-unix") == 0) {
            copyTxtWithFlags(src, dst, Unix, Unix, switchBool);
        } else {
            // Unrecognized target flag inputted
            return;
        }
        // not a valid type
    } else {
        // Unrecognized source flag inputted
        return;
    }
}

/**
 * This function is for task 2, it operates copyWithFlags function by the user values.
 * @param src source file name.
 * @param dst destination file name.
 * @param srcFlag operation system name the source uses.
 * @param dstFlag operation system name the destination needs.
 * @param byteOrder if a switch is needed.
 */
void copyWithFlagsAndEndianness(char *src, char *dst, char *srcFlag, char *dstFlag, char *byteOrder) {
    if (strcmp(byteOrder, "-keep") == 0) {
        copyWithFlags(src, dst, srcFlag, dstFlag, 0);
    } else if (strcmp(byteOrder, "-swap") == 0) {
        copyWithFlags(src, dst, srcFlag, dstFlag, 1);
    } else {
        // Bad option 3 flag (only swap or keep)
        return;
    }
}

/**
 * This main function gets the user input, and sends it to the proper function according to its size.
 * @param argc number of user arguments + 1.
 * @param argv the user arguments array of strings.
 * @return 0 after it's finished.
 */
int main(int argc, char **argv) {
    if (argc == 3) {
        copyTxt(argv[1], argv[2]);
    } else if (argc == 5) {
        copyWithFlags(argv[1], argv[2], argv[3], argv[4], 0);
    } else if (argc == 6) {
        copyWithFlagsAndEndianness(argv[1], argv[2], argv[3], argv[4], argv[5]);
    } else {
        // "No valid arguments
    }
    return 0;
}

