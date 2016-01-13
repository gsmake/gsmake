#ifndef LEMON_OS_ERRORS_HPP
#define LEMON_OS_ERRORS_HPP
#include <system_error>

namespace lemon{ namespace os{
	enum class errc 
	{
		command_not_found
	};

	class os_error_category : public std::error_category
	{
	private:

		const char *name() const throw()
		{
			return "lemon::os::os_error_category";
		}

		std::string message(int _Errval) const
		{
			switch ((errc)_Errval)
			{
			case errc::command_not_found:
				return "command execute not found";
			default:
				return "unknown error code";
			}
		}

		std::error_condition default_error_condition(int _Errval) const throw()
		{
			return std::error_condition(_Errval,*this);
		}

		bool equivalent(int _Errval,const std::error_condition& _Cond) const throw()
		{
			return _Errval == _Cond.value();
		}

		bool equivalent(const std::error_code& _Code, int _Errval) const throw()
		{
			return _Errval == _Code.value();
		}
	};


}}

namespace std{
	template<> struct is_error_code_enum<lemon::os::errc> : true_type {};

	/*inline std::error_condition make_error_condition(lemon::os::errc err)
	{
		return err
	}*/
}

#endif //LEMON_OS_ERRORS_HPP