# Common Headers

A list of important HTTP headers commonly used:

### 1. **Content-Security-Policy (CSP)**

- **Description**: Defines which content is allowed to load on a webpage. It restricts sources of scripts, styles, images, etc.
- **Example**:
  ```http
  Content-Security-Policy: default-src 'self'; script-src 'self' https://trusted-cdn.com
  ```
- **Prevents XSS**: Yes. It prevents the execution of malicious scripts by only allowing scripts from trusted sources.

### 2. **X-Content-Type-Options**

- **Description**: Forces the browser to stick to the MIME types specified in the `Content-Type` header.
- **Example**:
  ```http
  X-Content-Type-Options: nosniff
  ```
- **Prevents XSS**: Indirectly. It prevents the browser from interpreting files as something else (e.g., a text file being interpreted as JavaScript).

### 3. **X-XSS-Protection**

- **Description**: Activates the browser's XSS filter (although most modern browsers have it enabled by default).
- **Example**:
  ```http
  X-XSS-Protection: 1; mode=block
  ```
- **Prevents XSS**: Yes. It blocks or sanitizes the page when an XSS attack is detected by the browser.

### 4. **Referrer-Policy**

- **Description**: Controls how much referrer information (like the URL of the previous page) is sent with requests.
- **Example**:
  ```http
  Referrer-Policy: no-referrer
  ```
- **Prevents XSS**: No direct effect on XSS, but it improves privacy and security.

### 5. **Strict-Transport-Security (HSTS)**

- **Description**: Forces the browser to only communicate with the server using HTTPS, preventing man-in-the-middle attacks.
- **Example**:
  ```http
  Strict-Transport-Security: max-age=31536000; includeSubDomains; preload
  ```
- **Prevents XSS**: No direct effect on XSS, but it enforces secure communication.

### 6. **Access-Control-Allow-Origin (CORS)**

- **Description**: Specifies which domains are allowed to access resources on the server, thus preventing unauthorized cross-origin requests.
- **Example**:
  ```http
  Access-Control-Allow-Origin: https://trusted-domain.com
  ```
- **Prevents XSS**: No direct effect on XSS, but helps prevent unauthorized resource access.

### 7. **X-Frame-Options**

- **Description**: Controls whether your site can be embedded in an iframe by another website.
- **Example**:
  ```http
  X-Frame-Options: DENY
  ```
- **Prevents XSS**: Indirectly, by preventing clickjacking attacks where an attacker could inject malicious scripts within an iframe.

---

### Headers That Prevent XSS:

- **Content-Security-Policy (CSP)**: Strongly prevents XSS by controlling script execution.
- **X-XSS-Protection**: Helps prevent XSS by leveraging the browser’s built-in XSS filters.
- **X-Content-Type-Options**: Indirectly helps by enforcing the proper content type.
