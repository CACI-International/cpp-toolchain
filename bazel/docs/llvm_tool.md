<!-- Generated with Stardoc: http://skydoc.bazel.build -->



<a id="llvm_tool"></a>

## llvm_tool

<pre>
load("@portable_cc_toolchain//:llvm_tool.bzl", "llvm_tool")

llvm_tool(<a href="#llvm_tool-name">name</a>, <a href="#llvm_tool-tool">tool</a>, <a href="#llvm_tool-kwargs">**kwargs</a>)
</pre>

Access an LLVM tool by name.

Creates an executable target that can be called by other rules, e.g. genrules.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="llvm_tool-name"></a>name |  A unique name for this rule   |  `None` |
| <a id="llvm_tool-tool"></a>tool |  The name of the tool (e.g. `clang`)   |  `None` |
| <a id="llvm_tool-kwargs"></a>kwargs |  Extra arguments to pass to this rule   |  none |


<a id="llvm_tool_file"></a>

## llvm_tool_file

<pre>
load("@portable_cc_toolchain//:llvm_tool.bzl", "llvm_tool_file")

llvm_tool_file(<a href="#llvm_tool_file-tool">tool</a>)
</pre>

Return the label to an LLVM tool.

Returns a label to the file, rather than an executable rule.
This might be useful in repository rules that want to run an LLVM tool.


**PARAMETERS**


| Name  | Description | Default Value |
| :------------- | :------------- | :------------- |
| <a id="llvm_tool_file-tool"></a>tool |  The name of the tool (e.g. `clang`)   |  none |


