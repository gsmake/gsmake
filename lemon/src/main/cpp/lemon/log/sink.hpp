#ifndef LEMON_LOG_SINK_HPP
#define LEMON_LOG_SINK_HPP

#include <lemon/nocopy.hpp>

namespace lemon{ namespace log{

	/**
	 * the predeclared of message structure 
	 */
	struct message;

	class sink
	{
	public:
		virtual void write(const message & msg) = 0;
		virtual ~sink(){}
	};

	/**
	 * this is the console log sink implement
	 */
	class console : public sink,private nocopy
	{
	public:
		void write(const message & msg) final;
	};
}}


#endif //LEMON_LOG_SINK_HPP