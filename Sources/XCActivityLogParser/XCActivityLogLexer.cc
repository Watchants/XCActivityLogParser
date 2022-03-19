//
//  XCActivityLogLexer.cc
//  XCActivityLogParser
//
//  Created by tiger on 9/19/20.
//

#include "XCActivityLogLexer.h"

#include "XCActivityLogIterator.h"

#include <cstddef>
#include <fcntl.h>
#include <unistd.h>
#include <sys/stat.h>
#include <sys/mman.h>

namespace Watchants {

    XCActivityLogLexer::XCActivityLogLexer(const char *filepath) {
        this->fd = -1;
        this->size = 0;
        this->mem = nullptr;
        this->scanner = nullptr;

        if (filepath == nullptr) return;
        int fd = open(filepath, O_RDONLY);
        if (fd <= 0) return;

        struct stat st;
        if (fstat(fd, &st) != 0) return;
        if (st.st_size <= 0) return;

        uint8_t * mem = (uint8_t *)mmap(nullptr, st.st_size, PROT_READ, MAP_SHARED, fd, 0);
        if (mem == nullptr) return;
        if (mem == (void *)-1) return;

        this->fd = fd;
        this->size = st.st_size;
        this->mem = mem;
        this->scanner = new XCActivityLogScanner(this->mem, this->size);
    }

    XCActivityLogLexer::~XCActivityLogLexer() {
        if (this->mem != nullptr) {
            munmap(this->mem, this->size);
        }
        if (this->fd > 0) {
            close(this->fd);
        }
        if (this->scanner != nullptr) {
            delete this->scanner;
        }
        this->size = 0;
        this->fd = -1;
        this->mem = nullptr;
        this->scanner = nullptr;
    }

    XCActivityLogIterator * XCActivityLogLexer::iterator() {
        if (this->scanner != nullptr) {
            return new XCActivityLogIterator(this->scanner);
        } else {
            return nullptr;
        }
    }

}
