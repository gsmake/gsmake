/**
 * 
 * @file     classheap
 * @brief    Copyright (C) 2016  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2016/02/19
 */
#ifndef LEMON_GC_CLASS_HEAP_HPP
#define LEMON_GC_CLASS_HEAP_HPP

#include <cstdlib>
#include <cstdint>
#include <typeinfo>
#include <unordered_map>
#include <lemon/nocopy.hpp>

namespace lemon {
	namespace gc {

		struct gc_object
		{
			uint8_t			marked; // marked for destroy

			int				counter;

			char			buff[1];
		};

		template<typename Class>
		inline gc_object* gc_object_cast(Class *obj)
		{
			return reinterpret_cast<gc_object*>((uint8_t*)obj - offsetof(gc_object,buff));
		}

		template<typename Class>
		inline void make_destroy(void * buff, std::size_t)
		{
			((Class*)buff)->~Class();

			buff = nullptr;
		}

		class classheap : private nocopy
		{
		public:
			using destroy = void(*)(void * buff,std::size_t nsize);
		public:
			classheap(std::size_t size, destroy f):_size(size), _destroy(f),_idgen(1)
			{
				
			}

			~classheap()
			{
				for (auto iter : _objects)
				{
					if (iter.second->marked == 1)
					{
						_destroy(iter.second->buff, _size);
					}

					free(iter.second);
				}
			}

			gc_object * alloc(uint32_t & id)
			{
				for (;;)
				{
					if (_objects[_idgen] == nullptr)
					{
						id = _idgen ++;

						if (id == 0) id = _idgen++;

						std::size_t nsize = _size + sizeof(gc_object);

						gc_object * obj = (gc_object*)malloc(nsize);

						memset(obj,0, nsize);

						obj->marked		= 0;
						obj->counter	= 0;
						_objects[id] = obj;

						return obj;
					}
				}

				
			}

			gc_object * get(uint32_t id)
			{
				auto iter = _objects.find(id);

				if (iter != _objects.end())
				{
					if (iter->second->marked == 0)
					{
						return iter->second;
					}
				}

				return nullptr;
			}

			void dodestroy(gc_object *obj,uint32_t id)
			{
				if (obj->marked == 1)
				{
					_destroy(obj->buff, _size);
				}

				_objects.erase(id);
			}

		private:
			std::size_t									_size;
			destroy										_destroy;
			uint32_t									_idgen;
			std::unordered_map<uint32_t, gc_object*>	_objects;
		};
	}
}

#endif //LEMON_GC_CLASS_HEAP_HPP