<%
/** This code is copyright Articulate Software (c) 2003.  Some portions
copyright Teknowledge (c) 2003 and reused under the terms of the GNU license.
This software is released under the GNU Public License <http://www.gnu.org/copyleft/gpl.html>.
Users of this code also consent, by use of this code, to credit Articulate Software
and Teknowledge in any writings, briefings, publications, presentations, or
other representations of any software which incorporates, builds on, or uses this
code.  Please cite the following article in any publication with references:

Pease, A., (2003). The Sigma Ontology Development Environment,
in Working Notes of the IJCAI-2003 Workshop on Ontology and Distributed Systems,
August 9, Acapulco, Mexico. See also http://sigmakee.sourceforge.net
*/
 show = new StringBuffer();       // Variable to contain the HTML page generated.
 String formattedFormula = null;
 term = request.getParameter("term");
 nonRelTerm = request.getParameter("nonrelation");
 relTerm = request.getParameter("relation");
 Map theMap = null;     // Map of natural language format strings.
 KBPOS = request.getParameter("KBPOS");
 relREmatch = request.getParameter("relREmatch");
 nonRelREmatch = request.getParameter("nonRelREmatch");

 if (KBPOS == null && term == null)
    KBPOS = "1";
 else if (KBPOS == null && term != null)
 	KBPOS = kb.REswitch(term);
 
 HTMLformatter.kbHref = "http://" + hostname + ":" + port + "/sigma/" + parentPage + "?lang=" + language + "&flang=" + flang + "&kb=" + kbName;

 if (kb != null && StringUtil.emptyString(term) && StringUtil.emptyString(relTerm) && StringUtil.emptyString(nonRelTerm) && StringUtil.emptyString(relREmatch))        // Show statistics only when no term is specified.
    show.append(HTMLformatter.showStatistics(kb));
 else if (kb != null && term != null && !kb.containsTerm(term) && KBPOS.equals("1")) {           // Show the alphabetic neighbors of a term
    show.append(HTMLformatter.showNeighborTerms(kb,term));
    TreeMap tm = WordNet.wn.getSensesFromWord(term);
    if (tm != null) {
        show.append("<td width=\"10%\"><img src=\"pixmaps/1pixel.gif\" width=\"1\" height=\"1\" border=\"0\"></td>");
        show.append("<td width=\"40%\" valign=\"top\"><small>");
        show.append(WordNetUtilities.formatWordsList(tm,kbName));
        show.append("</small></td>");
    }
    show.append("</td></table>");
 }
 else if ((kb != null) && (term == null) && (nonRelTerm != null) && (relTerm != null) && KBPOS.equals("1")) {
    show.append(HTMLformatter.showNeighborTerms(kb,nonRelTerm, relTerm));
    show.append("</td></table>");
 }
 else if ((kb != null) && (term != null) && kb.containsTerm(term)) {  // Build the HTML format for all the formulas in
     term = kb.simplifyTerm(term);
     
     show.append("<title>Sigma KEE - " + term + "</title>\n");   // which the given term appears.
     show.append("<table width=\"95%\"><tr><td width=\"50%\"><font face=\"Arial,helvetica\" size=\"+3\"><b>");

     term = term.intern();
     show.append(term);
     show.append("</b></font>");
     boolean isArabic = (language.matches(".*(?i)arabic.*")
                         || language.equalsIgnoreCase("ar"));
     if (Character.isLowerCase(term.charAt(0)) || term.endsWith("Fn")) {
         Map fm = kb.getFormatMap(language);
         String fmValue = null;
         if (fm != null)
             fmValue = (String) fm.get(term);
         if (fmValue == null)
             System.out.println("INFO in BrowseBody.jsp: No format map entry for \"" +
                                term + "\" in language " + language);
     }
     else {
         Map tfm = kb.getTermFormatMap(language);
         String tfmValue = null;
         if (tfm != null)
             tfmValue = (String) tfm.get(term);
         if (tfmValue != null) {
             if (isArabic)
                 tfmValue = "<span dir=\"rtl\">" + tfmValue + "</span>";
             show.append("(" + tfmValue + ")");
         }
         else
             System.out.println("INFO in BrowseBody.jsp: No term format map entry for \"" +
                                term + "\" in language " + language);
         if (KBmanager.getMgr().getPref("userRole") != null &&
                 KBmanager.getMgr().getPref("userRole").equalsIgnoreCase("administrator")) {
             show.append(" [<a href=\"http://" + hostname + ":" + port + "/sigma/InstFiller.jsp?lang=" + language +
        	    	 "&flang=" + flang + "&kb=" + kbName + "&term=" + term + "\">assert facts</a>]<br>");
         }
         show.append(HTMLformatter.showMap(kb,term));
         show.append(HTMLformatter.showPictures(kb,term));
         show.append("</td>");
         TreeMap tm = WordNet.wn.getWordsFromTerm(term);
         if (tm != null) {
             show.append("<td width=\"10%\"><img src=\"pixmaps/1pixel.gif\" width=\"1\" height=\"1\" border=\"0\"></td>");
             show.append("<td width=\"40%\"><small>");
             if (language.equals("EnglishLanguage")) 
                 show.append(WordNetUtilities.formatWords(tm,kbName));
             else 
                 show.append(OMWordnet.formatWords(term,kbName,language,"http://" + hostname + ":" + port + "/sigma/"));             
             show.append("</small></td>");
         }
         else
             System.out.println("INFO in BrowseBody.jsp: No synsets for term " + term);
         show.append("</tr></table>\n");
     }
     show.append ("</b></font></td></tr></table>\n");

     int limit = Integer.decode(KBmanager.getMgr().getPref("userBrowserLimit")).intValue();
     if (KBmanager.getMgr().getPref("userRole") != null &&
         KBmanager.getMgr().getPref("userRole").equalsIgnoreCase("administrator")) {
         limit = Integer.decode(KBmanager.getMgr().getPref("adminBrowserLimit")).intValue();
     }

     for (int arg = 1; arg < 6; arg++) {
         String argHeader = ("appearance as argument number " + arg);
         show.append(HTMLformatter.browserSectionFormatLimit(term, argHeader, kb, language,flang,0,limit,arg,"arg"));
     }

     show.append(HTMLformatter.browserSectionFormatLimit(term, "antecedent", kb, language,flang,0,limit,0,"ant"));
     show.append(HTMLformatter.browserSectionFormatLimit(term, "consequent", kb, language,flang,0,limit,0,"cons"));
     show.append(HTMLformatter.browserSectionFormatLimit(term, "statement", kb, language,flang,0,limit,0,"stmt"));
     show.append(HTMLformatter.browserSectionFormatLimit(term, "appearance as argument number 0", kb, language,flang,0,limit,0,"arg"));

     show.append("<p><table align=\"left\" width=\"50%\"><tr><td bgcolor=\"#A8BACF\">" +
                 "<img src=\"pixmaps/1pixel.gif\" width=\"1\" height=\"1\" border=\"0\"></td></tr>" +
                 "</table><br>\n");
     if (!parentPage.equals("TreeView.jsp"))
         show.append("\n<small><a href=\"http://" + hostname + ":" + port + "/sigma/TreeView.jsp" +
                     "?lang=" + language + "&flang=" + flang + "&kb=" + kbName +
                     "&term=" + term + "\">Show full definition with tree view</a></small><br>\n");

     show.append("\n<small><a href=\"http://" + hostname + ":" + port + "/sigma/SimpleBrowse.jsp" +
                 "?lang=" + language + "&flang=" + flang + "&kb=" + kbName + "&simple=yes" +
                 "&term=" + term + "\">Show simplified definition (without tree view)</a></small><br>\n");
     show.append("\n<small><a href=\"http://" + hostname + ":" + port + "/sigma/TreeView.jsp" +
                 "?lang=" + language + "&flang=" + flang + "&kb=" + kbName + "&simple=yes" +
                 "&term=" + term + "\">Show simplified definition (with tree view)</a></small><p>\n");
 }
 else if (kb != null && term != null && kb.containsRE(term) && 
         KBPOS.equals("2") && relREmatch == null) {
 	ArrayList<String> matches = kb.getREMatch(term);
 	ArrayList<String> relMatches = HTMLformatter.getAllRelTerms(kb,matches);
 	ArrayList<String> nonRelMatches = HTMLformatter.getAllNonRelTerms(kb,matches);
 	relREmatch = relMatches.size()>0?relMatches.get(0):"";
 	nonRelREmatch = nonRelMatches.size()>0?nonRelMatches.get(0):"";
 	show.append(HTMLformatter.showREMatches(kb, relREmatch, nonRelREmatch, term));
 }
 else if (kb != null && term != null && kb.containsRE(term) && KBPOS.equals("2") && relREmatch != null) 
 	show.append(HTMLformatter.showREMatches(kb, relREmatch, nonRelREmatch, term));
 
 else if (kb != null && term != null && !kb.containsRE(term) && KBPOS.equals("2") && relREmatch == null) 
  	show.append("<b>No Matches Could Be Found </b>");

%>
