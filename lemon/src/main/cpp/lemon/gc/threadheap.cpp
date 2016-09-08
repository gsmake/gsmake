#include <lemon/gc/threadheap.hpp>

namespace lemon {
	namespace gc {

		threadheap _threadheap;

		threadheap & get_threadheap()
		{
			return _threadheap;
		}
	}
}