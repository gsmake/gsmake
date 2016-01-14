#ifndef LEMON_IO_ERRORS_HPP
#define LEMON_IO_ERRORS_HPP

#include <system_error>

namespace lemon { namespace io {
	enum class errc
	{
		operation_canceled,io_service_closed
	};

	class io_error_category : public std::error_category
	{
	private:

		const char *name() const throw()
		{
			return "lemon::os::os_error_category";
		}

		std::string message(int val) const
		{
			switch ((errc)val)
			{
			case errc::operation_canceled:
				return "io operation canceled";
			case errc::io_service_closed:
				return "io service closed";
			default:
				return "unknown error code";
			}
		}

		std::error_condition default_error_condition(int _Errval) const throw()
		{
			return std::error_condition(_Errval, *this);
		}

		bool equivalent(int _Errval, const std::error_condition& _Cond) const throw()
		{
			return _Errval == _Cond.value();
		}

		bool equivalent(const std::error_code& _Code, int _Errval) const throw()
		{
			return _Errval == _Code.value();
		}
	};
}}

namespace std {
	template<> struct is_error_code_enum<lemon::io::errc> : true_type {};


	inline error_code make_error_code(lemon::io::errc _Errno) _NOEXCEPT
	{
		static lemon::io::io_error_category io_error_category;

		return (error_code((int)_Errno, io_error_category));
	}
}
#endif //LEMON_IO_ERRORS_HPP