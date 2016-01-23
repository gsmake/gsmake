/**
 *
 * @file     io_operation
 * @brief    Copyright (C) 2015  yayanyang All Rights Reserved
 * @author   yayanyang
 * @date     2015/12/07
 */
#ifndef LEMON_IO_REACTIVE_OP_HPP
#define LEMON_IO_REACTIVE_OP_HPP

#include <cstddef>
#include <system_error>
#include <lemon/nocopy.hpp>

namespace lemon{
    namespace io{

        class reactor_op : private nocopy
        {
        public:
            reactor_op                 *next;
        protected:

            using action_f = bool(*)(reactor_op*);
            using complete_f = void(*)(reactor_op*);

            reactor_op(action_f action,complete_f complete)
                    :_action(action)
                    ,_complete(complete)
                    ,next(nullptr)
            {

            }

        public:
            bool action()
            {
                return _action(this);
            }

            void complete()
            {
                _complete(this);
            }

            void cancel(const std::error_code &ec)
            {
                _ec = ec;
            }

        private:

            action_f                    _action;
            complete_f                  _complete;

        protected:
            std::error_code             _ec;
            std::size_t                 _bytes_transferred;
        };
    }
}


#endif //LEMON_IO_REACTIVE_OP_HPP