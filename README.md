# Next.js + Stripe + Supabase Production-Ready Template

A production-ready Next.js template featuring authentication, dark mode support, Stripe integration, and a clean, modern UI. Built with TypeScript and Tailwind CSS.

![License](https://img.shields.io/badge/license-MIT-blue.svg)
![Next.js](https://img.shields.io/badge/Next.js-14-black)
![TypeScript](https://img.shields.io/badge/TypeScript-5.0-blue)
![Tailwind](https://img.shields.io/badge/Tailwind-3.0-38B2AC)

Full Video Guide: https://www.youtube.com/watch?v=ad1BxZufer8&list=PLE9hy4A7ZTmpGq7GHf5tgGFWh2277AeDR&index=8

## ✨ Features

- 🔐 Authentication with Supabase
- 💳 Stripe payment integration
- 🌓 Dark mode support
- 📱 Responsive design
- 🎨 Tailwind CSS styling
- 🔄 Framer Motion animations
- 🛡️ TypeScript support
- 📊 Error boundary implementation
- 🔍 SEO optimized

## 🚀 Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- A Supabase account
- A Stripe account
- A Google Cloud Platform account

### Installation and Setup

1. Clone the template:

```bash
git clone https://github.com/ShenSeanChen/yt-stripe-nextjs-supabase my-full-stack-app
cd my-full-stack-app
rm -rf .git
git init
git add .
git commit -m "Initial commit"
# git remote add origin https://github.com/ShenSeanChen/my-full-stack-app.git
git remote add origin https://github.com/USE_YOUR_OWN_GITHUB_NAME/my-full-stack-app.git
git push -u origin main
```

2. Install dependencies:
```bash
npm install
```
or
```bash
yarn install
```

3. Create .env.local with the following variables:
```
NEXT_PUBLIC_APP_URL=http://localhost:3000
NEXT_PUBLIC_API_URL=http://localhost:3000/api
NEXT_PUBLIC_WS_URL=ws://localhost:3000

# Supabase Configuration (from Project Settings > API)
NEXT_PUBLIC_SUPABASE_URL=https://your-project-id.supabase.co
NEXT_PUBLIC_SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-role-key

# OpenAI Configuration (only if you need it)
OPENAI_API_KEY=your-openai-key

# Stripe Configuration
NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY=pk_live_your-publishable-key
NEXT_PUBLIC_STRIPE_BUTTON_ID=buy_btn_your-button-id
STRIPE_SECRET_KEY=sk_live_your-secret-key
STRIPE_WEBHOOK_SECRET=whsec_your-webhook-secret

# ANALYTICS (only if you're using PostHog)
NEXT_PUBLIC_POSTHOG_KEY=your-posthog-key
NEXT_PUBLIC_POSTHOG_HOST=https://app.posthog.com
```

4. Set up Google Cloud Platform (GCP):
   - Create/access your GCP project
   - Go to API & Services > Credentials
   - Create new OAuth 2.0 credentials
   - Configure authorized JavaScript origins (your domain, e.g., http://localhost:3000)
   - Configure redirect URIs (your Supabase auth callback URL)
   - Save the Client ID and Client Secret for use in Supabase

5. Configure Supabase:

   a. Create a Supabase account and project:
      - Go to https://supabase.com/ and sign up/log in
      - Create a new project with a name of your choice
      - Set a secure database password

   b. Get API Keys (Project Settings > API):
      - Project URL → NEXT_PUBLIC_SUPABASE_URL
      - Anon Public Key → NEXT_PUBLIC_SUPABASE_ANON_KEY
      - Service Role Secret → SUPABASE_SERVICE_ROLE_KEY

   c. Set up Authentication:
      - Go to Authentication > Providers > Google
      - Add your GCP Client ID and Client Secret
      - Update Site URL (e.g., http://localhost:3000)
      - Update Redirect URLs (e.g., http://localhost:3000/auth/callback)

   d. Database Setup:
      - Go to SQL Editor in Supabase dashboard
      - Create a new query and paste the SQL from initial_supabase_table_schema.sql
      - This SQL will:
         1. Create all required tables
         2. Enable Row Level Security (RLS) for all tables
         3. Create policies for authenticated users and service roles
      - Run the SQL to create the database structure
      - Then add the trigger function with this SQL:

      ```sql
      CREATE OR REPLACE FUNCTION public.handle_new_user()
      RETURNS trigger AS $$
      BEGIN
        INSERT INTO public.users (id, email, created_at, updated_at, is_deleted)
        VALUES (NEW.id, NEW.email, NOW(), NOW(), FALSE);

        INSERT INTO public.user_preferences (user_id, has_completed_onboarding)
        VALUES (NEW.id, FALSE);

        INSERT INTO public.user_trials (user_id, trial_start_time, trial_end_time)
        VALUES (NEW.id, NOW(), NOW() + INTERVAL '48 hours');

        RETURN NEW;
      END;
      $$ LANGUAGE plpgsql SECURITY DEFINER;

      CREATE TRIGGER on_auth_user_created
        AFTER INSERT ON auth.users
        FOR EACH ROW EXECUTE FUNCTION public.handle_new_user();
      ```

6. Set up Stripe:
   a. Create a Stripe account (or use existing one):
      - Sign up at https://stripe.com/
      - Switch between test/live modes as needed (test recommended for development)

   b. Create products and pricing:
      - Go to Products > Add Product
      - Set name, description, and pricing details
      - Make note of the price_id for each product

   c. Get required API keys:
      - Dashboard > Developers > API keys
      - Publishable Key → NEXT_PUBLIC_STRIPE_PUBLISHABLE_KEY
      - Secret Key → STRIPE_SECRET_KEY

   d. Create a Buy Button (if needed):
      - Products > Select your product > Sell > Buy button
      - Customize settings and copy the button ID (after buy_btn_)
      - Set as NEXT_PUBLIC_STRIPE_BUTTON_ID

   e. Configure webhooks:
      - Dashboard > Developers > Webhooks > Add endpoint
      - Add endpoint URL: your_url/api/stripe/webhook
      - Select events to listen to: customer.subscription.*, checkout.session.*, invoice.*, payment_intent.*
      - After creation, reveal the Signing Secret
      - Copy Signing Secret → STRIPE_WEBHOOK_SECRET

7. Start the development server:
```bash
npm run dev
```
or
```bash
yarn dev
```

8. Open [http://localhost:3000](http://localhost:3000) in your browser.

9. Verify Your Setup:
   - Create a test user account by signing up
   - Check Supabase tables to confirm user data was created
   - Test the Stripe integration by attempting a subscription

## 📖 Project Structure

```
├── app/                  # Next.js 14 app directory
│   ├── api/              # API routes
│   │   ├── stripe/       # Stripe payment endpoints
│   │   └── user/         # User API endpoints
│   ├── auth/             # Auth-related pages
│   │   ├── callback/     # handle auth callback
│   ├── dashboard/        # Dashboard pages
│   ├── pay/              # Payment pages
│   ├── profile/          # User profile pages
│   ├── reset-password/   # Reset password pages
│   ├── update-password/  # Update password pages
│   ├── verify-email/     # Verify email pages
│   ├── layout.tsx        # Root layout
│   └── page.tsx          # Home page
├── components/           # Reusable components
├── contexts/             # React contexts
├── hooks/                # Custom React hooks
├── utils/                # Utility functions
├── types/                # TypeScript type definitions
├── public/               # Static assets
└── styles/               # Global styles
```

## 🛠️ Built With

- [Next.js](https://nextjs.org/) - React framework
- [TypeScript](https://www.typescriptlang.org/) - Type safety
- [Tailwind CSS](https://tailwindcss.com/) - Styling
- [Supabase](https://supabase.com/) - Authentication & Database
- [Stripe](https://stripe.com/) - Payments
- [Framer Motion](https://www.framer.com/motion/) - Animations

## 🔧 Configuration

### Tailwind Configuration

The template includes a custom Tailwind configuration with:
- Custom colors
- Dark mode support
- Extended theme options
- Custom animations

### Authentication

Authentication is handled through Supabase with support for:
- Email/Password
- Google OAuth
- Magic Links
- Password Reset

### Payment Integration

Stripe integration includes:
- Subscription management
- Trial periods
- Webhook handling
- Payment status tracking

## 🤝 Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Next.js team for the amazing framework
- Vercel for the deployment platform
- Tailwind CSS team for the utility-first CSS framework
- Supabase team for the backend platform
- Stripe team for the payment infrastructure

## 📫 Contact

X - [@ShenSeanChen](https://x.com/ShenSeanChen)

YouTube - [@SeanTechStories](https://www.youtube.com/@SeanTechStories)

Discord - [@Sean's Stories](https://discord.gg/TKKPzZheua)

Instagram - [@SeanTechStories](https://www.instagram.com/sean_tech_stories )

Project Link: [https://github.com/ShenSeanChen/yt-stripe-nextjs-supabase](https://github.com/ShenSeanChen/yt-stripe-nextjs-supabase)

## 🚀 Deploy

The easiest way to deploy your Next.js app is to use the [Vercel Platform](https://vercel.com/new?utm_medium=default-template&filter=next.js).

[![Deploy with Vercel](https://vercel.com/button)](https://vercel.com/new/clone?repository-url=https://github.com/yourusername/your-repo-name)

---

Made with 🔥 by [ShenSeanChen](https://github.com/ShenSeanChen)
