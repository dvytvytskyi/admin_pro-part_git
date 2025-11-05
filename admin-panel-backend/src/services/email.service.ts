import nodemailer from 'nodemailer';

// Email configuration from environment variables
const createTransporter = () => {
  // Check if using SMTP
  if (process.env.SMTP_HOST) {
    return nodemailer.createTransport({
      host: process.env.SMTP_HOST,
      port: parseInt(process.env.SMTP_PORT || '587'),
      secure: process.env.SMTP_PORT === '465', // true for 465, false for other ports
      auth: {
        user: process.env.SMTP_USER,
        pass: process.env.SMTP_PASSWORD,
      },
    });
  }

  // If no SMTP config, return null (will use console.log fallback)
  return null;
};

export const sendResetCodeEmail = async (email: string, code: string): Promise<void> => {
  const transporter = createTransporter();
  const fromEmail = process.env.EMAIL_FROM || process.env.SMTP_USER || 'noreply@foryou-realestate.com';

  if (!transporter) {
    // Fallback: log to console (for development)
    console.log(`[EMAIL] Password reset code for ${email}: ${code}`);
    console.log(`[EMAIL] This code will expire in 15 minutes.`);
    return;
  }

  try {
    const mailOptions = {
      from: fromEmail,
      to: email,
      subject: 'Password Reset Code - ForYou Real Estate',
      html: `
        <!DOCTYPE html>
        <html>
        <head>
          <meta charset="utf-8">
          <style>
            body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
            .container { max-width: 600px; margin: 0 auto; padding: 20px; }
            .header { background-color: #4F46E5; color: white; padding: 20px; text-align: center; border-radius: 8px 8px 0 0; }
            .content { background-color: #f9fafb; padding: 30px; border-radius: 0 0 8px 8px; }
            .code-box { background-color: #fff; border: 2px dashed #4F46E5; padding: 20px; text-align: center; margin: 20px 0; border-radius: 8px; }
            .code { font-size: 32px; font-weight: bold; color: #4F46E5; letter-spacing: 8px; }
            .warning { color: #dc2626; font-size: 14px; margin-top: 20px; }
            .footer { text-align: center; margin-top: 30px; color: #6b7280; font-size: 12px; }
          </style>
        </head>
        <body>
          <div class="container">
            <div class="header">
              <h1>Password Reset</h1>
            </div>
            <div class="content">
              <p>Hello,</p>
              <p>You have requested to reset your password for your ForYou Real Estate account.</p>
              <p>Please use the following code to reset your password:</p>
              
              <div class="code-box">
                <div class="code">${code}</div>
              </div>
              
              <p class="warning">⚠️ This code will expire in 15 minutes.</p>
              <p>If you did not request this password reset, please ignore this email.</p>
              
              <div class="footer">
                <p>ForYou Real Estate</p>
                <p>This is an automated message, please do not reply.</p>
              </div>
            </div>
          </div>
        </body>
        </html>
      `,
      text: `
Password Reset Code - ForYou Real Estate

You have requested to reset your password.

Your password reset code is: ${code}

This code will expire in 15 minutes.

If you did not request this password reset, please ignore this email.

ForYou Real Estate
      `.trim(),
    };

    await transporter.sendMail(mailOptions);
    console.log(`✅ Password reset email sent to ${email}`);
  } catch (error: any) {
    console.error('❌ Error sending email:', error);
    // Don't throw - fallback to console log
    console.log(`[EMAIL FALLBACK] Password reset code for ${email}: ${code}`);
  }
};

