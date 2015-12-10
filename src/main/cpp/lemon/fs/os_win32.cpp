#include <lemon/fs/os.hpp>

#ifdef WIN32

namespace lemon {namespace fs {


	filepath current_path(std::error_code &e) noexcept
	{
		wchar_t buff[MAX_PATH];

		DWORD length = ::GetCurrentDirectoryW(MAX_PATH, buff);

		if (length == 0)
		{
			e = std::error_code(GetLastError(), std::system_category());

			return "";
		}

		return filepath(std::wstring(buff, length));
	}

	void current_path(const filepath & path, std::error_code &err) noexcept
	{
		if (!::SetCurrentDirectoryW(path.wstring().c_str()))
		{
			err = std::error_code(GetLastError(), std::system_category());
		}
	}

	bool exists(const filepath & path) noexcept
	{
		if (INVALID_FILE_ATTRIBUTES == GetFileAttributesW(path.wstring().c_str()))
		{
			return false;
		}

		return true;
	}

	void create_directory(const filepath& path, std::error_code & err) noexcept
	{
		if (0 == CreateDirectoryW(path.wstring().c_str(), NULL))
		{
			err = std::error_code(GetLastError(), std::system_category());
		}
	}

	void create_symlink(const filepath &from, const filepath &to, std::error_code &err) noexcept
	{

		auto flags = is_directory(from) ? SYMBOLIC_LINK_FLAG_DIRECTORY : 0;



		if (0 == CreateSymbolicLinkW(to.wstring().c_str(), from.wstring().c_str(), flags)) {

			err = std::error_code(GetLastError(), std::system_category());
		}
	}


	bool is_directory(const filepath &source) noexcept
	{
		auto attrs = GetFileAttributesW(source.wstring().c_str());
		if (INVALID_FILE_ATTRIBUTES == attrs)
		{
			return false;
		}

		if ((attrs & FILE_ATTRIBUTE_DIRECTORY) != 0)
		{
			return true;
		}

		return false;
	}

	void remove_file(const filepath & path, std::error_code &err) noexcept
	{
		auto pathName = path.wstring();

		if (!is_directory(path))
		{
			for (;;)
			{
				if (0 == DeleteFileW(pathName.c_str())) {

					if (GetLastError() == ERROR_ACCESS_DENIED) {
						DWORD attrs = GetFileAttributesW(pathName.c_str());
						attrs &= ~FILE_ATTRIBUTE_READONLY;
						SetFileAttributesW(pathName.c_str(), attrs);
						continue;
					}

					err = std::error_code(GetLastError(), std::system_category());
				}

				break;
			}

			return;
		}

		if (0 == RemoveDirectoryW(pathName.c_str())) {
			err = std::error_code(GetLastError(), std::system_category());
		}
	}

}}


#endif