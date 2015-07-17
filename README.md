# HdfsUtils

Ruby gem that provides utilities (ls, find, cat, and others) for
HDFS (Hadoop Distributed File System).

This gem uses the webhdfs interface, which provides fast, compatible,
remote access to files and directories stored in HDFS.

## Environment

The following environment variables may be used to configure the utilities.

<table>
  <tr>
    <th>Variable</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>HDFS_HOST</tt></td>
    <td>The IP hostname of the webhdfs server.</td>
    <td>localhost</td>
  </tr>
  <tr>
    <td><tt>HDFS_PORT</tt></td>
    <td>The IP port number of the webhdfs service.</td>
    <td>50070</td>
  </tr>
  <tr>
    <td><tt>HDFS_USERNAME<tt></td>
    <td>The username used to access HDFS.</td>
    <td>The value of the shell environment USER variable.</td>
  </tr>
  <tr>
    <td><tt>HDFS_URI</tt></td>
    <td>The location of the webhdfs service: <tt>[webhdfs://]hostname[:port]<tt></td>
    <td>webhdfs://localhost:50070</td>
  </tr>
</table>

## Common Options

All of the utilities take the following options, which override the environment variables when specified.

<table>
  <tr>
    <th>Option</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>--hdfsuri=[webhdfs://]hostname[:port]</tt></td>
    <td>The location of the webhdfs service.</td>
    <td>webhdfs://localhost:50070</td>
  </tr>
  <tr>
    <td><tt>--log-level=[debug|info|warn|error|fatal]</tt></td>
    <td>Logging level.  When <tt>debug</tt> is specified, failures will generate a stack trace.</td>
    <td>fatal</td>
  </tr>
</table>
