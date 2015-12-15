include (CheckIncludeFiles)

CHECK_INCLUDE_FILES (sys/event.h LEMOON_KQUEUE_H)
CHECK_INCLUDE_FILES (sys/epoll.h LEMOON_HAS_EPOLL_H)

configure_file(lemon/config.h.in lemon/config.h IMMEDIATE)