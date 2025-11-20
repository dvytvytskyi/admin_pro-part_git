'use client'
import { Layout, Menu, Button } from 'antd'
import { useRouter, usePathname } from 'next/navigation'
import { 
  DashboardOutlined, 
  HomeOutlined, 
  UserOutlined, 
  BookOutlined, 
  FileTextOutlined, 
  MessageOutlined,
  WechatOutlined,
  SettingOutlined,
  LogoutOutlined
} from '@ant-design/icons'
import { message } from 'antd'

const { Sider, Content, Header } = Layout

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const router = useRouter()
  const pathname = usePathname()

  const menuItems = [
    { key: '/dashboard', icon: <DashboardOutlined />, label: 'Dashboard' },
    { key: '/properties', icon: <HomeOutlined />, label: 'Нерухомість' },
    { key: '/users', icon: <UserOutlined />, label: 'Користувачі' },
    { key: '/knowledge-base', icon: <BookOutlined />, label: 'База Знань' },
    { key: '/news', icon: <FileTextOutlined />, label: 'Новини' },
    { key: '/chat', icon: <WechatOutlined />, label: 'Чати' },
    { key: '/support', icon: <MessageOutlined />, label: 'Підтримка' },
    { key: '/settings', icon: <SettingOutlined />, label: 'Налаштування' },
  ]

  const handleLogout = () => {
    localStorage.removeItem('token')
    message.success('Ви вийшли з системи')
    router.push('/login')
  }

  return (
    <Layout style={{ minHeight: '100vh' }}>
      <Sider theme="dark" width={250}>
        <div style={{ 
          color: 'white', 
          padding: 16, 
          fontSize: 20,
          fontWeight: 'bold',
          textAlign: 'center',
          borderBottom: '1px solid rgba(255,255,255,0.1)'
        }}>
          Admin Panel
        </div>
        <Menu
          theme="dark"
          mode="inline"
          selectedKeys={[pathname]}
          items={menuItems}
          onClick={({ key }) => router.push(key)}
          style={{ border: 'none' }}
        />
      </Sider>
      <Layout>
        <Header style={{ 
          background: '#fff', 
          padding: '0 24px', 
          display: 'flex',
          justifyContent: 'flex-end',
          alignItems: 'center',
          borderBottom: '1px solid #f0f0f0'
        }}>
          <Button 
            icon={<LogoutOutlined />} 
            onClick={handleLogout}
          >
            Вийти
          </Button>
        </Header>
        <Content style={{ margin: 24, background: '#fff', padding: 24, borderRadius: 8 }}>
          {children}
        </Content>
      </Layout>
    </Layout>
  )
}

