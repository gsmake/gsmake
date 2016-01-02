return [==[
cmake_minimum_required(VERSION 3.3)
project(@Name)

add_executable(@project.Name
@{{
    for _,project in ipairs(Projects) do

    end
}})

@-- create project modules
@for _,project in ipairs(Projects) do
    @if project.Type == "exe" then
add_executable(@project.Name
    @elseif project.Type == "static" then
add_library(@project.Name STATIC
    @else
add_library(@project.Name SHARED
    @end
    @for _,file in ipairs(project) do
    @file
    @end)
@end

]==]
