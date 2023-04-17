const root = window.location.href;

window.onload = function() {
    // document.getElementById("input").focus();
    // reset.innerHTML = "";
}

async function doClick() {
    // const a = document.createElement("a");
    area = document.getElementById("input").value;
    link = await sendPaste(area);
    url = await link.text();
    // console.log(url);

    window.history.replaceState(null, null, url)
    // window.location.href = url;

    // a.href = a.textContent = "http://localhost:8082/" + url;
    // a.target = "_blank";
    // document.getElementById("link").appendChild(a);
}

async function sendPaste(paste) {
    paste_url = root + 'paste';

    const response = await fetch(paste_url, {
        method: 'POST',
        body: paste,
        headers: {
        'Content-Type': 'application/json'
        }
    });
    const myJson = await response; //extract JSON from the http response
    // console.log(myJson.text());
    return myJson
}

function doCopy() {
    const textarea = document.getElementById("input").value;

    // textarea.select()
    // textarea.setSelectionRange(0, 99999);
    navigator.clipboard.writeText(textarea);
}

async function validate(username, password) {
    auth_url = root + 'admin/validate';

    const user_hash = await hash(username);
    const pass_hash = await hash(password);
    console.log(user_hash);
    console.log(pass_hash);

    // json = "{" + 

    // const response = await fetch(paste_url, {
    //     method: 'POST',
    //     body: paste,
    //     headers: {
    //     'Content-Type': 'application/json'
    //     }
    // });
}

async function hash(string) {
    const utf8 = new TextEncoder().encode(string);
    const hashBuffer = await crypto.subtle.digest('SHA-256', utf8);
    const hashArray = Array.from(new Uint8Array(hashBuffer));
    const hashHex = hashArray
      .map((bytes) => bytes.toString(16).padStart(2, '0'))
      .join('');
    return hashHex;
  }