<!DOCTYPE html>
<html>
  <script>
    var ctx = "<%=request.getContextPath()%>";
    console.log("ctx = " + ctx);
    var aaaa = "${pageContext.request.contextPath}";
    console.log("aaa = " + aaaa);
    var users = [];
    var sortField = "createdTime";
    var sortOrder = "ASC";

    var userCellIndexes = {
      "id": 0,
      "name": 1,
      "password": 2,
      "roles": 3,
      "createdTime": 4,
      "modifiedTime": 5,
      "save": 6,
      "delete": 7
    }

    function createUser() {
      var newUser = {
        "id": users.length,
        "name": "" + users.length,
        "password": "******",
        "roles": ["role" + users.length]
      }
      
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          console.log("received response from server: " + this.responseText);
          updateUsersTable();
        }
      };
      var usersUrl = getContextUrl() + "/users"
      xhttp.open("POST", usersUrl, true);
      xhttp.setRequestHeader("Content-Type", "application/json");
      xhttp.send(JSON.stringify(newUser));
    }

    function getContextUrl() {
      var full = location.protocol + "//" + location.hostname + (location.port ? ":" + location.port: "");
      return full + ctx;
    }

    function getUsers(callback) {
      var usersUrl = getContextUrl() + "/users?sortField=" + sortField + "&sortOrder=" + sortOrder;
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4 && this.status == 200) {
          console.log("received response from server: " + this.responseText);
          users = JSON.parse(this.responseText);
          if (callback) { callback() }
        }
      };
      xhttp.open("GET", usersUrl, true);
      xhttp.send();
    }

    function getCellValue(userIndex, userProp) {
      userIndex = parseInt(userIndex);
      var cellIndex = userCellIndexes[userProp];
      var usersTable = document.getElementById("usersTable");
      if (cellIndex === userCellIndexes.id) {
        return usersTable.rows[userIndex + 1].cells[cellIndex].innerHTML;
      } else {
        return usersTable.rows[userIndex + 1].cells[cellIndex].getElementsByTagName("div")[0].innerHTML;
      }
    }

    function pad(num) {
      return num > 10 ? num : "0" + num;
    }

    function formatDate(millis) {
      var date = new Date(millis);
      return date.getDate() + "-" + pad(date.getMonth()) + "-" + date.getFullYear() + " " +
             pad(date.getHours()) + ":" + pad(date.getMinutes()) + ":" + pad(date.getSeconds()) + "." + date.getMilliseconds()
    }

    function saveButtonDisplay(userIndex) {
      userIndex = parseInt(userIndex);
      var user = users[userIndex];
      var showSaveButton = false;
      var usersTable = document.getElementById("usersTable");
      var userCells = usersTable.rows[userIndex + 1].cells;
      // if any cell modified - show save button; otherwise - hide it
      var visible = (user.name !== getCellValue(userIndex, "name")) ||
                    (user.password !== getCellValue(userIndex, "password")) ||
                    (JSON.stringify(user.roles) !== JSON.stringify((getCellValue(userIndex, "roles").split(","))));
      console.log("saveButtonDisplay: visible = " + visible)
      userCells[userCellIndexes.save].style.visibility = visible ? "visible" : "hidden";
    }

    function editable(userIndex, content) {
      return "<div contenteditable onblur=\"saveButtonDisplay('" + userIndex + "')\" " +
                    "style=\"border-style: solid;" +
                    "border-width: 2px;" +
                    "border-color: lightblue;" +
                    "border-radius: 5px;\">" +
                content +
              "</div>";
    }

    function updateUsersTable() {
      getUsers(function() {
        clearUsersTable();
        var usersTable = document.getElementById("usersTable");
        users.forEach(function(singleUser, index) {

          var row = usersTable.insertRow(usersTable.rows.length);

          var idCell = row.insertCell(userCellIndexes.id);
          var nameCell = row.insertCell(userCellIndexes.name);
          var passwordCell = row.insertCell(userCellIndexes.password);
          var rolesCell = row.insertCell(userCellIndexes.roles);
          var createdCell = row.insertCell(userCellIndexes.createdTime);
          var modifiedCell = row.insertCell(userCellIndexes.modifiedTime);
          var saveCell = row.insertCell(userCellIndexes.save);
          var deleteCell = row.insertCell(userCellIndexes.delete);

          idCell.innerHTML = singleUser.id;
          nameCell.innerHTML = editable(index, singleUser.name);
          passwordCell.innerHTML = editable(index, singleUser.password);
          rolesCell.innerHTML = editable(index, singleUser.roles);
          modifiedCell.innerHTML = formatDate(singleUser.modifiedTime);
          createdCell.innerHTML = formatDate(singleUser.createdTime);
          saveCell.innerHTML = "<button type=\"button\" style=\"cursor: pointer\" onclick=\"saveUser('" + index + "')\">save</button>";
          saveCell.style.visibility = "hidden";
          deleteCell.innerHTML = "<button type=\"button\" style=\"cursor: pointer\" onclick=\"deleteUser('" + singleUser.id + "')\">delete</button>";
        });
      });
    }

    function clearUsersTable() {
      var usersTable = document.getElementById("usersTable");
      console.log("clearUsersTable START: " + usersTable.rows.length)
      // skip deletion of header row
      var numOfDisplayedUsers = usersTable.rows.length
      for (var i = 1; i < numOfDisplayedUsers; i++) {
        console.log("clearUsersTable: deleting row num " + i)
        usersTable.deleteRow(usersTable.rows.length - 1);
      }
      console.log("clearUsersTable END: " + usersTable.rows.length);
    }

    function saveUser(userIndex) {
      userIndex = parseInt(userIndex);
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          console.log("received response from server: " + this.responseText);
          updateUsersTable();
        }
      };
      var user = users[userIndex];
      var updatedUser = {
        "id": getCellValue(userIndex, "id"),
        "name": getCellValue(userIndex, "name"),
        "roles": getCellValue(userIndex, "roles").split(",")
      }
      var password = getCellValue(userIndex, "password");
      if (password !== "******") {
        updatedUser.password = password;
      }
      var usersUrl = getContextUrl() + "/users/" + user.id
      xhttp.open("PUT", usersUrl, true);
      xhttp.setRequestHeader("Content-Type", "application/json");
      console.log("sending: " + JSON.stringify(updatedUser));
      xhttp.send(JSON.stringify(updatedUser));
    }

    function deleteUser(userId) {
      var xhttp = new XMLHttpRequest();
      xhttp.onreadystatechange = function() {
        if (this.readyState == 4) {
          console.log("received response from server: " + this.responseText);
          if (this.status == 409) {
            alert(JSON.parse(this.responseText).message);
          } else if (this.status == 204) {
            updateUsersTable();
          }
        }
      };
      var usersUrl = getContextUrl() + "/users/" + userId
      xhttp.open("DELETE", usersUrl, true);
      xhttp.send();
    }

    function toggleHelp() {
      var help = document.getElementById("help");
      var h2 = document.getElementsByTagName("h2")[0];
      if (help.style.display === "block") {
        help.style.display = "none";
        h2.innerHTML = "+ Help (click to expand)";
      } else {
        help.style.display = "block";
        h2.innerHTML = "- Help (click to collapse)";
      }
      
    }

    function sortBy(field) {
      if (sortField === field) { // only flip sortOrder:
        sortOrder = sortOrder === "ASC" ? "DESC" : "ASC";
      } else { // set new sortField and sortOrder to ASC
        sortField = field;
        sortOrder = "ASC";
      }
      updateUsersTable();
    }
  </script>
<body onload="updateUsersTable()">

    <h2 onclick="toggleHelp()" style="cursor: pointer">+ Help (click to expand)</h2>
    <div id="help" style="display: none">
    <h3>Create User</h3>
    To create a new user, click the "create new user" button.<br>
    <h3>Edit User</h3>
    To edit a user, click inside one of the editable cells, make the desired modification
    and click the "save" button that will appear on the right end of the row. The editable
    cells, and them alone, have a light-blue border. The "save" button appears only if a
    real modification have been made, so editting a value to the exact same value as has
    been before-hand - would make the "save" button hidden.<br>
    <h3>Delete User</h3>
    To delete a user, simply click the "delete" button on the row of the user to delete.<br>
    <h3>Permissions</h3>
    Currently any string can function as a role. The "Roles" field may accept a list of roles,
    delimited by a comma (',').
    <h3>List Users by Permissions</h3>
    By clicking the headers of the Users table, its rows are sorted according to the clicked
    header. Clicking the same header consequently toggle the sort order - ascending or descending.
    Default sort column is "Created" and default order is ascending.<br>
    NOTE: the "Password" column is not eligible for sort, for security reasons :P (for that matter,
    the password is also always masked).
    </div>

    <br><br>

  <button type="button" onclick="createUser()" style="cursor: pointer">create new user</button><br><br>

  <table id="usersTable">
    <thead>
      <tr>
        <th onclick="sortBy('id')" style="cursor: pointer">Id</th>
        <th onclick="sortBy('name')" style="cursor: pointer">Name</th>
        <th>Password</th>
        <th onclick="sortBy('roles')" style="cursor: pointer">Roles</th>
        <th onclick="sortBy('createdTime')" style="cursor: pointer">Created</th>
        <th onclick="sortBy('modifiedTime')" style="cursor: pointer">Modified</th>
      </tr>
    </thead>
  </table>
</body>
</html>