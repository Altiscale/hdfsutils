require_relative '../spec_helper'
require 'utils/hls/ls'

describe HdfsUtils::Ls do
  it 'should ls a directory' do
    test_root_stat = {
      'FileStatus' => {
        'accessTime' => 0,
        'blockSize' => 0,
        'childrenNum' => 10,
        'fileId' => 16386,
        'group' => 'hdfs',
        'length' => 0,
        'modificationTime' => 1433791576835,
        'owner' => 'hdfs',
        'pathSuffix' => '',
        'permission' => '755',
        'replication' => 0,
        'type' => 'DIRECTORY'
      }
    }

    test_dir_stat = {
      'FileStatus' => {
        'accessTime' => 0,
        'blockSize' => 0,
        'childrenNum' => 2,
        'fileId' => 16580,
        'group' => 'users',
        'length' => 0,
        'modificationTime' => 1431723784561,
        'owner' => 'testuser',
        'pathSuffix' => '',
        'permission' => '755',
        'replication' => 0,
        'type' => 'DIRECTORY'
      }
    }

    ctheader = {'Content-Type' => 'application/json'}

    hostname = 'nn-cluster.nsdc.altiscale.com'
    port = '50070'
    username = 'testuser'

    testrooturl = 'http://' + hostname + ':' + port +
                  '/webhdfs/v1/?op=GETFILESTATUS&user.name=' +
                  username

    dirname = '/user/testuser/testdir'
    testdirurl = 'http://' + hostname + ':' + port +
                 '/webhdfs/v1' + dirname +
                 '?op=GETFILESTATUS&user.name=' +
                 username

    stub_request(:get, testrooturl)
      .to_return(:body => JSON.generate(test_root_stat),
                 :headers => ctheader)

    stub_request(:get, testdirurl)
      .to_return(:body => JSON.generate(test_dir_stat),
                 :headers => ctheader)

    ENV['HDFS_HOST'] = hostname
    ENV['HDFS_PORT'] = port
    ENV['HDFS_USERNAME'] = username

    ls_output = 'drwxr-xr-x   - testuser users ' +
                '         0 2015-05-15 21:03 ' +
                dirname + "\n"

    expect { HdfsUtils::Ls.new(['--log-level', 'dEbUg', dirname]).run }
      .to output(ls_output)
      .to_stdout
  end
end

