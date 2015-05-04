xquery version "1.0";
(:~
This is a component file of the VdU Software for a Virtual Research Environment for the handling of Medieval charters.

As the source code is available here, it is somewhere between an alpha- and a beta-release, may be changed without any consideration of backward compatibility of other parts of the system, therefore, without any notice.

This file is part of the VdU Virtual Research Environment Toolkit (VdU/VRET).

The VdU/VRET is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

VdU/VRET is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with VdU/VRET.  If not, see <http://www.gnu.org/licenses/>.

We expect VdU/VRET to be distributed in the future with a license more lenient towards the inclusion of components into other systems, once it leaves the active development stage.
:)

module namespace annotation="http://itineranova.be/NS/annotation";

import module namespace conf="http://www.monasterium.net/NS/conf"
    at "../conf/conf.xqm";
import module "http://exist-db.org/xquery/util";

declare namespace xmldb="http://exist-db.org/xquery/xmldb";
declare namespace xrx="http://www.monasterium.net/NS/xrx";
declare namespace tei="http://www.tei-c.org/ns/1.0/";
declare namespace atom="http://www.w3.org/2005/Atom";

(: 
    Functions of the annotation module: 
    - create
    - edit (public | privat | request)
    - publish
    - report
    Annotations
:)

(: insert bracket tags into strings :)
declare function annotation:insert-bracket-tag($stringdata as xs:string) as item()*
{
let $front-strings := tokenize($stringdata, '\(')
let $bracket := 
                for $string in $front-strings
                return
                    if(contains($string, ')'))then
                        (<tei:abbr type="glyph">{substring-before($string, ')')}</tei:abbr>,
                        substring-after($string, ')'))
                    else
                        $string
return
    $bracket
};

(: edit a private annotation :)
declare function annotation:edit-private-annotation($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
let $category := substring-before(substring-after($data, 'category='), '?!')
let $keyword := annotation:insert-bracket-tag(substring-before(substring-after($data, 'keyword='), '?!'))
let $transcription := annotation:insert-bracket-tag(substring-before(substring-after($data, 'transcription='), '?!'))
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('xrx-user-db-base-uri'), xmldb:decode($user), '/metadata.annotation.private/', xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $user }</tei:authority>
                                                        <tei:p>privat</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ $category }" id="{ $anno-id }">
                                            			{
                                            			(
                                            			let $surfaces := $old-annotation//tei:surface
                                            			for $surface in $surfaces
                                            			return
                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
                                                   ),
                                                   <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>,  
                                                   <tei:interp type="keyword">{ $keyword }</tei:interp>, 
                                                   <tei:span type="transcription">{ $transcription }</tei:span>
                                                   }  
                                                </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: edit a public annotation :)
declare function annotation:edit-public-annotation($data as xs:string, $anno-id as xs:string) as node()*
{
let $category := substring-before(substring-after($data, 'category='), '?!')
let $keyword := annotation:insert-bracket-tag(substring-before(substring-after($data, 'keyword='), '?!'))
let $transcription := annotation:insert-bracket-tag(substring-before(substring-after($data, 'transcription='), '?!'))
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('annotation-db-base-uri'), xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $public-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/public/annotation/{ xmldb:decode($registerid) }/{ xmldb:decode($folio) }/{ xmldb:decode($anno-id) }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ $annotation//xrx:id/text() }</xrx:id>
                                    <xrx:who>{ xmldb:decode($annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ $annotation//xrx:when/text() }</xrx:when>
                                    <xrx:operation>public</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
		                                            <tei:surfaceGrp type="{ $category }" id="{ string($annotation//tei:surfaceGrp/@id) }">
		                                            			{
		                                            			(
		                                            			let $surfaces := $annotation//tei:surface
		                                            			for $surface in $surfaces
		                                            			return
		                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
		                                                   ),
		                                                   <tei:graphic url="{ string($annotation//tei:graphic/@url) }"/>,  
		                                                   <tei:interp type="keyword">{ $keyword }</tei:interp>, 
		                                                   <tei:span type="transcription">{ $transcription }</tei:span>
		                                                   }  
                                                </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $public-data 
};

(: stop the publication process of an annotation:)
declare function annotation:stop-publication($old-annotation as node()*) as node()*
{
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                            <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                                    <tei:teiHeader>
                                                        <tei:fileDesc>
                                                            <tei:titleStmt>
                                                                <tei:title/>
                                                            </tei:titleStmt>
                                                            <tei:editionStmt>
                                                                <tei:p/>
                                                            </tei:editionStmt>
                                                            <tei:extent/>
                                                            <tei:publicationStmt>
                                                                <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                                <tei:p>privat</tei:p>
                                                            </tei:publicationStmt>
                                                            <tei:seriesStmt>
                                                                <tei:p/>
                                                            </tei:seriesStmt>
                                                            <tei:notesStmt>
                                                                <tei:note/>
                                                            </tei:notesStmt>
                                                            <tei:sourceDesc>
                                                                <tei:p/>
                                                            </tei:sourceDesc>
                                                        </tei:fileDesc>
                                                        <tei:revisionDesc>
                                                            <tei:change/>
                                                        </tei:revisionDesc>
                                                    </tei:teiHeader>
                                                    <tei:facsimile>
                                                            {
                                                            $old-annotation//tei:surfaceGrp
                                                            }
                                                   </tei:facsimile>
                                             </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: resend a request to moderator to publish an annotation :)
declare function annotation:resend-request($data as xs:string, $old-annotation as node()*) as node()*
{
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ xmldb:decode($old-annotation//xrx:revision/xrx:id/text()) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>request</xrx:operation>
                                    <xrx:annotation>{ $old-annotation//xrx:annotation/tei:TEI }</xrx:annotation>
                                    <xrx:comment>{ $data }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: edit the annotation of a request :)
declare function annotation:edit-request-annotation($data as xs:string, $old-annotation as node()*) as node()*
{
let $category := substring-before(substring-after($data, 'category='), '?!')
let $keyword := annotation:insert-bracket-tag(substring-before(substring-after($data, 'keyword='), '?!'))
let $transcription := annotation:insert-bracket-tag(substring-before(substring-after($data, 'transcription='), '?!'))
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ xmldb:decode($old-annotation//xrx:revision/xrx:id/text()) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                                    <xrx:operation>{ $old-annotation//xrx:operation/text() }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                                    <tei:teiHeader>
                                                        <tei:fileDesc>
                                                            <tei:titleStmt>
                                                                <tei:title/>
                                                            </tei:titleStmt>
                                                            <tei:editionStmt>
                                                                <tei:p/>
                                                            </tei:editionStmt>
                                                            <tei:extent/>
                                                            <tei:publicationStmt>
                                                                <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                                <tei:p>request</tei:p>
                                                            </tei:publicationStmt>
                                                            <tei:seriesStmt>
                                                                <tei:p/>
                                                            </tei:seriesStmt>
                                                            <tei:notesStmt>
                                                                <tei:note/>
                                                            </tei:notesStmt>
                                                            <tei:sourceDesc>
                                                                <tei:p/>
                                                            </tei:sourceDesc>
                                                        </tei:fileDesc>
                                                        <tei:revisionDesc>
                                                            <tei:change/>
                                                        </tei:revisionDesc>
                                                    </tei:teiHeader>
                                                    <tei:facsimile>
                                                    			<tei:surfaceGrp type="{ $category }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                            			{
					                                            			(
					                                            			let $surfaces := $old-annotation//tei:surface
					                                            			for $surface in $surfaces
					                                            			return
					                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
					                                                   ),
					                                                   <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>,  
					                                                   <tei:interp type="keyword">{ $keyword }</tei:interp>, 
					                                                   <tei:span type="transcription">{ $transcription }</tei:span>
					                                                   }  
					                                                </tei:surfaceGrp>
                                                   </tei:facsimile>
                                                </tei:TEI>
                                   </xrx:annotation>
                                    <xrx:comment>{ $old-annotation//xrx:comment/text() }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: basic function - create an annotation :)
declare function annotation:create-annotation($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $url := substring-before(substring-after($data, 'url='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $surface-id := concat($x1, $x2, $y1, $y2, $size)
let $category := substring-before(substring-after($data, 'category='), '?!')
let $keyword := annotation:insert-bracket-tag(substring-before(substring-after($data, 'keyword='), '?!'))
let $transcription := annotation:insert-bracket-tag(substring-before(substring-after($data, 'transcription='), '?!'))
let $registerid := xmldb:decode(substring-before(substring-after($data, 'registerid='), '?!'))
let $folio := xmldb:decode(substring-before(substring-after($data, 'folio='), '?!'))
let $annotation := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/user/annotation/{ $registerid }/{ $folio }/{ $anno-id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $user }</tei:authority>
                                                        <tei:p>privat</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ $category }" id="{ $anno-id }">
					                                         <tei:surface id="{ $surface-id }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>
					                                         <tei:graphic url="{ $url }"/> 
					                                         <tei:interp type="keyword">{ $keyword }</tei:interp> 
					                                         <tei:span type="transcription">{ $transcription }</tei:span>
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: send a request to moderator to publish an annotation :)
declare function annotation:send-to-moderator($user as xs:string, $anno-id as xs:string) as node()*
{
let $registerid := request:get-parameter("registerid","0")
let $folio := request:get-parameter("folio","0")
let $annotation-path := concat(conf:param('xrx-user-db-base-uri'), xmldb:decode($user), '/metadata.annotation.private/', xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//tei:TEI
let $request-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/request/annotation/{ $registerid }/{ $folio }/{ $anno-id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>tag:itineranova.be,2011:/user/annotation/{ $registerid }/{ $folio }/{ $anno-id }</xrx:id>
                                    <xrx:who>{ xmldb:decode($xrx:user-id) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>request</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>request</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($annotation//tei:surfaceGrp/@type) }" id="{ string($annotation//tei:surfaceGrp/@id) }">
						                                         {
						                                         (
			                                            	 let $surfaces := $annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                         }  
						                                     </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $request-data 
};

(: publish an annotation  :)
declare function annotation:publish-annotation($annotation as node()*, $anno-id as xs:string) as node()*
{
let $registerid := xmldb:encode(request:get-parameter("registerid","0"))
let $folio := xmldb:encode(request:get-parameter("folio","0"))
let $public-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/public/annotation/{ $registerid }/{ $folio }/{ $anno-id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>tag:itineranova.be,2011:/user/annotation/{ $registerid }/{ $folio }/{ $anno-id }</xrx:id>
                                    <xrx:who>{ xmldb:decode($annotation//tei:authority/text()) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>public</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            			<tei:surfaceGrp type="{ string($annotation//tei:surfaceGrp/@type) }" id="{ string($annotation//tei:surfaceGrp/@id) }">
						                                         {
						                                         (
			                                            	 let $surfaces := $annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                         }  
						                                     </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $public-data 
};

(: answer a request to publish an annotation :)
declare function annotation:answer-request($type as xs:string, $moderator-annotation as node()*, $anno-id as xs:string, $comment as xs:string) as node()*
{
let $registerid := xmldb:encode(request:get-parameter("registerid","0"))
let $folio := xmldb:encode(request:get-parameter("folio","0"))
let $answer-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/user/annotation/{ $registerid }/{ $folio }/{ $anno-id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>tag:itineranova.be,2011:/user/annotation/{ $registerid }/{ $folio }/{ $anno-id }</xrx:id>
                                    <xrx:who>{ xmldb:decode($moderator-annotation//tei:authority/text()) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>{ $type }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $moderator-annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>request</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            			<tei:surfaceGrp type="{ string($moderator-annotation//tei:surfaceGrp/@type) }" id="{ string($moderator-annotation//tei:surfaceGrp/@id) }">
					                                         {
					                                         (
			                                            	 let $surfaces := $moderator-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                             ),
			                                             <tei:graphic url="{ string($moderator-annotation//tei:graphic/@url) }"/>,
					                                         <tei:interp type="keyword">{ $moderator-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
                                                   <tei:span type="transcription">{ $moderator-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
					                                         }  
					                                     </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment>{ $comment }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $answer-data 
};

(: answer a request to publish an annotation :)
declare function annotation:answer-report($type as xs:string, $moderator-annotation as node()*, $anno-id as xs:string, $comment as xs:string) as node()*
{
let $registerid := xmldb:encode(request:get-parameter("registerid","0"))
let $folio := xmldb:encode(request:get-parameter("folio","0"))
let $answer-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/report/annotation/{ $registerid }/{ $folio }/{ $anno-id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ $moderator-annotation//xrx:id/text() }</xrx:id>
                                    <xrx:who>{ xmldb:decode($moderator-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>{ if($type = 'true')then xs:string('deleted') else xs:string('answered') }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $moderator-annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>request</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                               <tei:surfaceGrp type="{ string($moderator-annotation//tei:surfaceGrp/@type) }" id="{ string($moderator-annotation//tei:surfaceGrp/@id) }">
					                                         {
					                                         (
			                                            	 let $surfaces := $moderator-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                             ),
			                                             <tei:graphic url="{ string($moderator-annotation//tei:graphic/@url) }"/>,
					                                         <tei:interp type="keyword">{ $moderator-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
                                                   <tei:span type="transcription">{ $moderator-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
					                                         }  
					                                     </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment>{ $moderator-annotation//xrx:comment/text() }</xrx:comment>
                                    <xrx:responseComment>{ $comment }</xrx:responseComment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $answer-data 
};

(: send a report to your moderator :)
declare function annotation:report-to-moderator($annotation as node()*, $user as xs:string, $id as xs:string, $comment as xs:string){
let $registerid := xmldb:decode(request:get-parameter("registerid","0"))
let $folio := xmldb:decode(request:get-parameter("folio","0"))
let $report-data := 
                    <atom:entry>
                        <atom:id>tag:itineranova.be,2011:/report/annotation/{ $registerid }/{ $folio }/{ $id }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>tag:itineranova.be,2011:/public/annotation/{ $registerid }/{ $folio }/{ string($annotation//tei:surfaceGrp/@id) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($user) }</xrx:who>
                                    <xrx:when>{ current-date() }</xrx:when>
                                    <xrx:operation>report</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                                   <tei:surfaceGrp type="{ string($annotation//tei:surfaceGrp/@type) }" id="{ string($annotation//tei:surfaceGrp/@id) }">
					                                         {
					                                         (
		                                            	 let $surfaces := $annotation//tei:surface
		                                            	 for $surface in $surfaces
		                                            			return
		                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
		                                               ),
		                                               <tei:graphic url="{ string($annotation//tei:graphic/@url) }"/>,
					                                         <tei:interp type="keyword">{ $annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
                                                   <tei:span type="transcription">{ $annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
					                                         }  
					                                     </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment>{ $comment }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
   $report-data 
};

(: add surface to a privat annotation :)
declare function annotation:add-privat-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $surface-id := concat($x1, $x2, $y1, $y2, $size)
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('xrx-user-db-base-uri'), xmldb:decode($user), '/metadata.annotation.private/', xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $user }</tei:authority>
                                                        <tei:p>privat</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:surface id="{ $surface-id }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>,
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: add surface to a public annotation :)
declare function annotation:add-public-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $surface-id := concat($x1, $x2, $y1, $y2, $size)
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('annotation-db-base-uri'), xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                        	<xrx:revision>
                             <xrx:id>{ $old-annotation//xrx:id/text() }</xrx:id>
                             <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                             <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                             <xrx:operation>public</xrx:operation>
                             <xrx:annotation>       
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:surface id="{ $surface-id }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>,
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: add surface to a request annotation :)
declare function annotation:add-request-surface($data as xs:string, $old-annotation as node()*) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $surface-id := concat($x1, $x2, $y1, $y2, $size)
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ xmldb:decode($old-annotation//xrx:revision/xrx:id/text()) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                                    <xrx:operation>{ $old-annotation//xrx:operation/text() }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                                    <tei:teiHeader>
                                                        <tei:fileDesc>
                                                            <tei:titleStmt>
                                                                <tei:title/>
                                                            </tei:titleStmt>
                                                            <tei:editionStmt>
                                                                <tei:p/>
                                                            </tei:editionStmt>
                                                            <tei:extent/>
                                                            <tei:publicationStmt>
                                                                <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                                <tei:p>request</tei:p>
                                                            </tei:publicationStmt>
                                                            <tei:seriesStmt>
                                                                <tei:p/>
                                                            </tei:seriesStmt>
                                                            <tei:notesStmt>
                                                                <tei:note/>
                                                            </tei:notesStmt>
                                                            <tei:sourceDesc>
                                                                <tei:p/>
                                                            </tei:sourceDesc>
                                                        </tei:fileDesc>
                                                        <tei:revisionDesc>
                                                            <tei:change/>
                                                        </tei:revisionDesc>
                                                    </tei:teiHeader>
                                                    <tei:facsimile>
                                                    			<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
										                                         {
											                                         (
								                                            	 let $surfaces := $old-annotation//tei:surface
								                                            	 for $surface in $surfaces
								                                            	 return
								                                                   <tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
								                                               ),
								                                               <tei:surface id="{ $surface-id }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>,
								                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
											                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
						                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
											                                       }  
										                                      </tei:surfaceGrp>
                                                   </tei:facsimile>
                                                </tei:TEI>
                                   </xrx:annotation>
                                    <xrx:comment>{ $old-annotation//xrx:comment/text() }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: edit surface of a privat annotation :)
declare function annotation:edit-privat-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('xrx-user-db-base-uri'), xmldb:decode($user), '/metadata.annotation.private/', xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $user }</tei:authority>
                                                        <tei:p>privat</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                            	 		 if(string($surface/@id) = $search-id)then
			                                            	 		 	<tei:surface id="{ string($surface/@id) }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>
			                                            	 		 else
			                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: edit surface of a public annotation :)
declare function annotation:edit-public-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('annotation-db-base-uri'), xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                        	<xrx:revision>
                             <xrx:id>{ $old-annotation//xrx:id/text() }</xrx:id>
                             <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                             <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                             <xrx:operation>public</xrx:operation>
                             <xrx:annotation>       
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   if(string($surface/@id) = $search-id)then
			                                            	 		 	<tei:surface id="{ string($surface/@id) }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>
			                                            	 		 else
			                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: edit surface of a request annotation :)
declare function annotation:edit-request-surface($data as xs:string, $old-annotation as node()*) as node()*
{
(: get data parameters of post request :)
let $size := substring-before(substring-after($data, 'size='), '?!')
let $x1 := substring-before(substring-after($data, 'x1='), '?!')
let $x2 := substring-before(substring-after($data, 'x2='), '?!')
let $y1 := substring-before(substring-after($data, 'y1='), '?!')
let $y2 := substring-before(substring-after($data, 'y2='), '?!')
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ xmldb:decode($old-annotation//xrx:revision/xrx:id/text()) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                                    <xrx:operation>{ $old-annotation//xrx:operation/text() }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                                    <tei:teiHeader>
                                                        <tei:fileDesc>
                                                            <tei:titleStmt>
                                                                <tei:title/>
                                                            </tei:titleStmt>
                                                            <tei:editionStmt>
                                                                <tei:p/>
                                                            </tei:editionStmt>
                                                            <tei:extent/>
                                                            <tei:publicationStmt>
                                                                <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                                <tei:p>request</tei:p>
                                                            </tei:publicationStmt>
                                                            <tei:seriesStmt>
                                                                <tei:p/>
                                                            </tei:seriesStmt>
                                                            <tei:notesStmt>
                                                                <tei:note/>
                                                            </tei:notesStmt>
                                                            <tei:sourceDesc>
                                                                <tei:p/>
                                                            </tei:sourceDesc>
                                                        </tei:fileDesc>
                                                        <tei:revisionDesc>
                                                            <tei:change/>
                                                        </tei:revisionDesc>
                                                    </tei:teiHeader>
                                                    <tei:facsimile>
                                                    			<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                            			{
					                                            			(
					                                            			let $surfaces := $old-annotation//tei:surface
					                                            			for $surface in $surfaces
					                                            			return
					                                                   if(string($surface/@id) = $search-id)then
					                                            	 		 	<tei:surface id="{ string($surface/@id) }" ulx="{ $x1 }" uly="{ $y1 }" lrx="{ $x2 }" lry="{ $y2 }"/>
					                                            	 		 else
					                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
					                                               		 ),
					                                                   <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>,  
					                                                   <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   				 <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span> 
					                                                   }  
					                                                </tei:surfaceGrp>
                                                   </tei:facsimile>
                                                </tei:TEI>
                                   </xrx:annotation>
                                    <xrx:comment>{ $old-annotation//xrx:comment/text() }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: delete a surface of a privat annotation :)
declare function annotation:delete-privat-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('xrx-user-db-base-uri'), xmldb:decode($user), '/metadata.annotation.private/', xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $user }</tei:authority>
                                                        <tei:p>privat</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                            	 		 if(string($surface/@id) = $search-id)then
			                                            	 		 		()
			                                            	 		 else
			                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: delete a surface of a request annotation :)
declare function annotation:delete-request-surface($data as xs:string, $old-annotation as node()*) as node()*
{
(: get data parameters of post request :)
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                                <xrx:revision>
                                    <xrx:id>{ xmldb:decode($old-annotation//xrx:revision/xrx:id/text()) }</xrx:id>
                                    <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                                    <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                                    <xrx:operation>{ $old-annotation//xrx:operation/text() }</xrx:operation>
                                    <xrx:annotation>
                                        <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                                    <tei:teiHeader>
                                                        <tei:fileDesc>
                                                            <tei:titleStmt>
                                                                <tei:title/>
                                                            </tei:titleStmt>
                                                            <tei:editionStmt>
                                                                <tei:p/>
                                                            </tei:editionStmt>
                                                            <tei:extent/>
                                                            <tei:publicationStmt>
                                                                <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                                <tei:p>request</tei:p>
                                                            </tei:publicationStmt>
                                                            <tei:seriesStmt>
                                                                <tei:p/>
                                                            </tei:seriesStmt>
                                                            <tei:notesStmt>
                                                                <tei:note/>
                                                            </tei:notesStmt>
                                                            <tei:sourceDesc>
                                                                <tei:p/>
                                                            </tei:sourceDesc>
                                                        </tei:fileDesc>
                                                        <tei:revisionDesc>
                                                            <tei:change/>
                                                        </tei:revisionDesc>
                                                    </tei:teiHeader>
                                                    <tei:facsimile>
                                                    			<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                            			{
					                                            			(
					                                            			let $surfaces := $old-annotation//tei:surface
					                                            			for $surface in $surfaces
					                                            			return
					                                                   if(string($surface/@id) = $search-id)then
					                                            	 		 	()
					                                            	 		 else
					                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
					                                               		 ),
					                                                   <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>,  
					                                                   <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   				 <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span> 
					                                                   }  
					                                                </tei:surfaceGrp>
                                                   </tei:facsimile>
                                                </tei:TEI>
                                   </xrx:annotation>
                                    <xrx:comment>{ $old-annotation//xrx:comment/text() }</xrx:comment>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};

(: delete a surface of a public annotation :)
declare function annotation:delete-public-surface($data as xs:string, $user as xs:string, $anno-id as xs:string) as node()*
{
(: get data parameters of post request :)
let $search-id := substring-before(substring-after($data, 'surfaceID='), '?!')
(: get old annotation to copy contents :)
let $registerid := substring-before(substring-after($data, 'registerid='), '?!')
let $folio := substring-before(substring-after($data, 'folio='), '?!')
let $annotation-path := concat(conf:param('annotation-db-base-uri'), xmldb:decode($registerid), '/', xmldb:decode($folio), '/')
let $file-name := concat(translate($anno-id, '.', '_'), '.xml')
let $old-annotation := doc(xmldb:encode-uri(concat($annotation-path, $file-name)))//atom:entry
let $annotation := 
                    <atom:entry>
                        <atom:id>{ $old-annotation//atom:id/text() }</atom:id>
                        <atom:title/>
                        <atom:published></atom:published>
                        <atom:updated></atom:updated>
                        <atom:author>
                            <atom:email></atom:email>
                        </atom:author>
                        <app:control xmlns:app="http://www.w3.org/2007/app">
                            <app:draft>no</app:draft>
                        </app:control>
                        <atom:content type="application/xml">
                        	<xrx:revision>
                             <xrx:id>{ $old-annotation//xrx:id/text() }</xrx:id>
                             <xrx:who>{ xmldb:decode($old-annotation//xrx:who/text()) }</xrx:who>
                             <xrx:when>{ $old-annotation//xrx:when/text() }</xrx:when>
                             <xrx:operation>public</xrx:operation>
                             <xrx:annotation>       
                                <tei:TEI xmlns:tei="http://www.tei-c.org/ns/1.0/">
                                            <tei:teiHeader>
                                                <tei:fileDesc>
                                                    <tei:titleStmt>
                                                        <tei:title/>
                                                    </tei:titleStmt>
                                                    <tei:editionStmt>
                                                        <tei:p/>
                                                    </tei:editionStmt>
                                                    <tei:extent/>
                                                    <tei:publicationStmt>
                                                        <tei:authority>{ $old-annotation//tei:authority/text() }</tei:authority>
                                                        <tei:p>public</tei:p>
                                                    </tei:publicationStmt>
                                                    <tei:seriesStmt>
                                                        <tei:p/>
                                                    </tei:seriesStmt>
                                                    <tei:notesStmt>
                                                        <tei:note/>
                                                    </tei:notesStmt>
                                                    <tei:sourceDesc>
                                                        <tei:p/>
                                                    </tei:sourceDesc>
                                                </tei:fileDesc>
                                                <tei:revisionDesc>
                                                    <tei:change/>
                                                </tei:revisionDesc>
                                            </tei:teiHeader>
                                            <tei:facsimile>
                                            		<tei:surfaceGrp type="{ string($old-annotation//tei:surfaceGrp/@type) }" id="{ string($old-annotation//tei:surfaceGrp/@id) }">
					                                         {
						                                         (
			                                            	 let $surfaces := $old-annotation//tei:surface
			                                            	 for $surface in $surfaces
			                                            	 return
			                                                   if(string($surface/@id) = $search-id)then
			                                            	 		 	()
			                                            	 		 else
			                                                   	<tei:surface id="{ string($surface/@id) }" ulx="{ string($surface/@ulx) }" uly="{ string($surface/@uly) }" lrx="{ string($surface/@lrx) }"  lry="{ string($surface/@lry) }"/>
			                                               ),
			                                               <tei:graphic url="{ string($old-annotation//tei:graphic/@url) }"/>, 
						                                         <tei:interp type="keyword">{ $old-annotation//tei:surfaceGrp/tei:interp[@type='keyword']/child::node() }</tei:interp>, 
	                                                   <tei:span type="transcription">{ $old-annotation//tei:surfaceGrp/tei:span[@type='transcription']/child::node() }</tei:span>  
						                                       }  
					                                      </tei:surfaceGrp>
                                           </tei:facsimile>
                                        </tei:TEI>
                                    </xrx:annotation>
                                    <xrx:comment/>
                                </xrx:revision>
                        </atom:content>
                    </atom:entry>
return
    $annotation
};