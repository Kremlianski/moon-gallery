MMG = window.MMG 

MMG.Templates.Simple = {}

MMG.Templates.Simple.template =

  "
  <div class='<%=meta.NS %>-img <%= data.classList %>'
  data-image-id='<%= imageId %>'>
  <% if(data.href) { %>
    <a href='<%= data.href %>' class='<%=meta.NS %>-link' rel='gal'>
  <% } %>
  <% if(data.face) { %>
    <div class='<%=meta.NS %>-f-caption'>
  <% if(data.face&&data.face.descr) { %>
      <div class='<%=meta.NS %>-descr'>
        <span class='<%=meta.NS %>-caption-bg'>
        <%= data.face.descr %>
        </span>
      </div>
  <% } %>
  <% if(data.face&&data.face.title) { %>
      <h3 class='<%=meta.NS %>-title'>
        <span class='<%=meta.NS %>-title-bg'>
        <%= data.face.title %>
        </span>
      </h3>
  <% } %>
  <% if(data.face&&data.face.secondDescr) { %>
      <div class='<%=meta.NS %>-footer'>
        <span class='<%=meta.NS %>-caption-bg'>
        <%= data.face.secondDescr %>
        </span>
      </div>
  <% } %>
    </div>
  <% } %>
    <img class='<%=meta.NS %>-icon <%=meta.NS %>-fs' src='<%= data.src %>'>
  <% if(data.href) { %>
    </a>
  <% } %>
  </div>
  "
  
MMG.Templates.Simple.defaults =
  templateName: 'Simple'
