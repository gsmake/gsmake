/**
 * 
 * @file     gc
 * @brief    Copyright (C) 2016  yayanyang All Rights Reserved 
 * @author   yayanyang
 * @date     2016/02/19
 */
#ifndef LEMON_GC_GC_HPP
#define LEMON_GC_GC_HPP

#include <utility>
#include <type_traits>
#include <lemon/gc/threadheap.hpp>

namespace lemon {
	namespace gc {

		template<typename Class>
		class let;
		
		template<typename Class>
		class ref
		{
		public:
			ref() :_ref(0) {}

			ref(referid id) :_ref(id)
			{

			}

			operator bool() const
			{
				return _ref != 0;
			}

			let<Class> lock();

		private:
			referid	_ref;
		};

		template<typename Class>
		class let
		{
		public:
			let():let(nullptr,0)
			{

			}

			template<class T,
			class = typename std::enable_if<std::is_convertible<T *, Class *>::value, void>::type
			>
			let(ref<T> rhs)
			{
				*this = rhs.lock();
			}

			let(Class* obj, referid id)
				:ptr(obj),id(id)
			{

			}

			~let()
			{
				unlock();
				
			}

			let(const let&) = delete;


			let(let<Class> && rhs)
			{
				ptr = std::move(rhs.ptr);

				id = std::move(rhs.id);
			}

			template<class T,
			class = typename std::enable_if<std::is_convertible<T *, Class *>::value,void>::type 
			>
			let(let<T> && rhs) noexcept
			{

				ptr = rhs.ptr;

				rhs.ptr = nullptr;

				id = rhs.id;

				rhs.id = 0;
			}

			let & operator = (let & rhs) = delete;

			template<class T,
			class = typename std::enable_if<std::is_convertible<T *, Class *>::value, void>::type
			>
			let & operator = (let<T>&& rhs)
			{
				let tmp;

				std::swap(ptr, tmp.ptr);
				std::swap(id, tmp.id);

				ptr = rhs.ptr;

				id = rhs.id;

				rhs.ptr = nullptr;

				rhs.id = 0;

				return *this;
			}

			operator bool() const
			{
				return ptr != nullptr;
			}

			Class* operator ->() const
			{
				return ptr;
			}

			ref<Class> unlock()
			{
				if (*this)
				{
					get_threadheap().unlock(ptr, id);

					ptr = nullptr;

					ref<Class> r(id);

					id = 0;

					return r;
				}
				
				return{};
			}

			operator ref<Class>()
			{
				return ref<Class>(id);
			}

			template<typename T,
			class = typename std::enable_if<std::is_convertible<T *, Class *>::value, void>::type
			>
			operator ref<T>()
			{
				return ref<T>(id);
			}

			template<typename T,
			class = typename std::enable_if<std::is_convertible<T *, Class *>::value, void>::type
			>
			let& operator = (ref<T> rhs)
			{
				*this = rhs.lock();

				return *this;
			}
		
			Class				*ptr;
			referid				id;
		};

		template<typename Class>
		inline let<Class> ref<Class>::lock()
		{
			return let<Class>(get_threadheap().lock<Class>(_ref), _ref);
		}

		template<typename Class, typename... Args>
		inline let<Class> gc_new(Args && ...args)
		{
			referid id;

			auto obj = get_threadheap().create<typename std::remove_cv<Class>::type>(id, std::forward<Args>(args)...);

			return let<Class>(obj,id);
		}

		inline void collect()
		{
			get_threadheap().collect();
		}

		class collect_guard final
		{
		public:
			collect_guard() = default;

			~collect_guard()
			{
				collect();
			}
		};
	}
}

#endif //LEMON_GC_GC_HPP