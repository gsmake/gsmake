#include <lemon/gc/threadheap.hpp>

namespace lemon {
	namespace gc {

		thread_local threadheap _threadheap;

		threadheap & get_threadheap()
		{
			return _threadheap;
		}
	}
}