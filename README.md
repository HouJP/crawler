****

##<center>Crawler Written in Shell</center>
####<center>Author: HouJP_NSD</center>
####<center>E-mail: houjp1992@gmail.com</center>

****

###目录
*	[项目介绍](#intro)
*	[版本更新](#version)
*	[使用说明](#usage)

****

###<a name="intro">项目介绍</a>

使用Shell脚本写的爬虫程序，或者说是一个框架，爬取的动作可以自己写程序定制，修改配置文件即可。

没有系统学习Shell编程，应该有挺多不尽人意的地方，欢迎指正。

****

###<a name="version">版本更新</a>

*	[2015/03/15]
	1.	可以配置多个种子URL进行爬取。
	2.	修正链接抽取的BUG，可抽取相对路径的URL。

****

###<a name="usage">使用说明</a>

*	运行前需要安装Python的 requests，安装方法如下
	1.	先下载requests包(https://github.com/kennethreitz/requests)
	2.	先执行 sudo python setup.py build
	3.	然后执行 python setup.py install

*	运行方法
	1.	程序启动 ./Run.sh start
	2.	程序暂停 	./Run.sh stop

*	目录结构说明
	*	./bin/	存放脚本程序
	*	./conf/	存放配置文件
	*	./data/	存放数据文件
	*	./flag/	存放程序运行中间状态
	*	./log/	存放日志文件



****
