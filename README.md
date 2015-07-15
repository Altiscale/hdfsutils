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
    <td><tt>HDFS_URL</tt></td>
    <td>The location of the HDFS: <tt>[webhdfs://]hostname[:port]<tt>
    <td>TODO: SPECIFY HOW THE HADOOP CONFIG FILES ARE FOUND/USED.</td>
  </tr>
  <tr>
    <td><tt>HDFS_USER<tt></td>
    <td>The username used to access HDFS.</td>
    <td>The username on the local system.</td>
  </tr>
</table>

## Common Options

All of the utilities take the following options:

  --hdfsurl=[webhdfs://]hostname[:port]
