/**
 * Utility function to redirect to login page
 * Ensures redirect stays on the same domain
 */
export function redirectToLogin() {
  if (typeof window !== 'undefined') {
    const currentOrigin = window.location.origin;
    window.location.href = `${currentOrigin}/login`;
  }
}

