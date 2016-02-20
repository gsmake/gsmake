/**
 * 
 * @file     threadheap
 * @brief    Copyright (C) 2016  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2016/02/19
 */
#ifndef LEMON_GC_THREADHEAP_HPP
#define LEMON_GC_THREADHEAP_HPP

#include <atomic>
#include <typeinfo>
#include <utility>
#include <type_traits>
#include <unordered_map>
#include <lemon/nocopy.hpp>
#include <lemon/gc/classheap.hpp>

namespace lemon {
	namespace gc {

		using referid = uint64_t;

		class threadheap : private nocopy
		{
		public:
			
			threadheap()
			{
				static std::atomic<uint32_t> id;

				_id = id++;

				_id = (_id << 32) & 0xffffffff00000000;
			}

			~threadheap()
			{
				for(auto iter : _classheaps)
				{
					delete iter.second;
				}
			}

			uint64_t id()
			{
				return _id;
			}

			template<typename Class, typename... Args>
			Class* create(referid &id,Args && ...args)
			{
				typedef typename std::remove_cv<Class>::type T;

				auto typeinfo = &typeid((T*)0);

				auto heap = _classheaps[typeinfo];

				if (heap == nullptr)
				{
					heap = new classheap(sizeof(T), make_destroy<T>);
					_classheaps[typeinfo] = heap;
				}

				uint32_t objid;

				auto gcobj = heap->alloc(objid);

				id = _id | objid;

				try
				{
					return new(gcobj->buff)T(std::forward<Args>(args)...);
				}
				catch (...)
				{
					gcobj->marked = gc_object::black;
					heap->unlock(gcobj, objid);
					throw;
				}
				
			}

			template<typename Class>
			Class* lock(referid id)
			{
				typedef typename std::remove_cv<Class>::type T;

				auto typeinfo = &typeid((T*)0);

				auto iter = _classheaps.find(typeinfo);

				if (iter != _classheaps.end())
				{
					auto gcobj = iter->second->lock((uint32_t)(id&0xffffffff));

					if (gcobj)
					{
						return (T*)gcobj->buff;
					}
				}

				return nullptr;
			}

			template<typename Class>
			void unlock(Class* obj,referid id)
			{
				typedef typename std::remove_cv<Class>::type T;

				auto gcobj = gc_object_cast<Class>(obj);
				

				auto iter = _classheaps.find(&typeid((T*)0));

				if (iter != _classheaps.end())
				{
					iter->second->unlock(gcobj, (uint32_t)(id & 0xffffffff));
				}
			}

			template<typename Class>
			void destroy(Class* obj, referid)
			{

				auto iter = _classheaps.find(typeinfo);

				if (iter != _classheaps.end())
				{
					gc_object_cast<Class>(obj)->marked = gc_object::gray;
					iter->second->unlock(gcobj, (uint32_t)(id & 0xffffffff));
				}
			}


			void collect()
			{
				for (auto kv : _classheaps)
				{
					kv.second->collect();
				}
			}

		private:
			std::unordered_map<const std::type_info*, classheap*>	_classheaps;
			uint64_t												_id;
		};

		threadheap & get_threadheap();
	}
}

#endif //LEMON_GC_THREADHEAP_HPP