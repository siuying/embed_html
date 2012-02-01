Dependencies
============

 * Hpricot
 * Typhoeus

Install
=======

> gem install embed_html

Usage
=======

> eurl _&lt;input-url&gt;_ _&lt;output-file&gt;_

Example:

> eurl "http://en.wikipedia.org/wiki/Wiki" wiki.html

Output:

>	I, [2010-05-20T15:56:58.315769 #26393]  INFO -- : downloading url: http://en.wikipedia.org/wiki/Wiki

>	I, [2010-05-20T15:57:02.033068 #26393]  INFO -- : done
	
The file wiki.html then contains the specified page, with all of the images embeded

