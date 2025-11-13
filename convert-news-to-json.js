const fs = require('fs');
const path = require('path');

// Стокові фото про Дубай (Unsplash)
const dubaiImages = [
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Dubai skyline
  'https://images.unsplash.com/photo-1539650116574-75c0c6d73a6e?w=1200&h=800&fit=crop', // Burj Khalifa
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&h=800&fit=crop', // Dubai Marina
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Modern Dubai
  'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=1200&h=800&fit=crop', // Dubai buildings
  'https://images.unsplash.com/photo-1581067721837-e2149b4e6d7e?w=1200&h=800&fit=crop', // Dubai architecture
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&h=800&fit=crop', // Dubai cityscape
  'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=1200&h=800&fit=crop', // Dubai modern
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&h=800&fit=crop', // Dubai towers
  'https://images.unsplash.com/photo-1539650116574-75c0c6d73a6e?w=1200&h=800&fit=crop', // Dubai skyline 2
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Dubai view
  'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=1200&h=800&fit=crop', // Dubai buildings 2
  'https://images.unsplash.com/photo-1581067721837-e2149b4e6d7e?w=1200&h=800&fit=crop', // Dubai architecture 2
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&h=800&fit=crop', // Dubai cityscape 2
  'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=1200&h=800&fit=crop', // Dubai modern 2
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&h=800&fit=crop', // Dubai towers 2
  'https://images.unsplash.com/photo-1539650116574-75c0c6d73a6e?w=1200&h=800&fit=crop', // Dubai skyline 3
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Dubai view 2
  'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=1200&h=800&fit=crop', // Dubai buildings 3
  'https://images.unsplash.com/photo-1581067721837-e2149b4e6d7e?w=1200&h=800&fit=crop', // Dubai architecture 3
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&h=800&fit=crop', // Dubai cityscape 3
  'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=1200&h=800&fit=crop', // Dubai modern 3
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&h=800&fit=crop', // Dubai towers 3
  'https://images.unsplash.com/photo-1539650116574-75c0c6d73a6e?w=1200&h=800&fit=crop', // Dubai skyline 4
  'https://images.unsplash.com/photo-1512453979798-5ea266f8880c?w=1200&h=800&fit=crop', // Dubai view 3
  'https://images.unsplash.com/photo-1518684079-3c830dcef090?w=1200&h=800&fit=crop', // Dubai buildings 4
  'https://images.unsplash.com/photo-1581067721837-e2149b4e6d7e?w=1200&h=800&fit=crop', // Dubai architecture 4
  'https://images.unsplash.com/photo-1571896349842-33c89424de2d?w=1200&h=800&fit=crop', // Dubai cityscape 4
  'https://images.unsplash.com/photo-1524231757912-21f4fe3a7200?w=1200&h=800&fit=crop', // Dubai modern 4
  'https://images.unsplash.com/photo-1559827260-dc66d52bef19?w=1200&h=800&fit=crop', // Dubai towers 4
  'https://images.unsplash.com/photo-1539650116574-75c0c6d73a6e?w=1200&h=800&fit=crop', // Dubai skyline 5
];

function parseNewsFile(filePath) {
  const content = fs.readFileSync(filePath, 'utf-8');
  const lines = content.split('\n');
  
  const articles = [];
  let currentArticle = null;
  let currentContent = [];
  let order = 0;
  
  for (let i = 0; i < lines.length; i++) {
    const line = lines[i].trim();
    
    // Перевірка на початок нової статті
    if (line.match(/^Стаття \d+$/)) {
      // Зберегти попередню статтю, якщо вона є
      if (currentArticle) {
        if (currentContent.length > 0) {
          currentArticle.contents = currentContent;
        }
        articles.push(currentArticle);
      }
      
      // Почати нову статтю
      currentArticle = {
        title: '',
        description: '',
        imageUrl: dubaiImages[articles.length % dubaiImages.length],
        isPublished: true,
        publishedAt: new Date().toISOString(),
        contents: []
      };
      currentContent = [];
      order = 0;
      continue;
    }
    
    // Пропустити порожні рядки на початку статті
    if (!currentArticle) continue;
    
    // Якщо заголовок порожній, це заголовок
    if (!currentArticle.title && line) {
      currentArticle.title = line;
      continue;
    }
    
    // Якщо опис порожній, це опис (перший абзац)
    if (!currentArticle.description && line) {
      currentArticle.description = line;
      continue;
    }
    
    // Якщо рядок порожній після опису, пропустити
    if (!line && !currentArticle.description) continue;
    
    // Обробка контенту
    if (line) {
      // Перевірка, чи це підзаголовок (великі літери або короткий рядок без крапки)
      const isSubtitle = line.length < 100 && 
                        (line === line.toUpperCase() || 
                         !line.includes('.') || 
                         line.endsWith(':') ||
                         /^[А-ЯЁ]/.test(line));
      
      if (isSubtitle && currentContent.length > 0) {
        // Додати попередній текстовий блок, якщо є
        order++;
      }
      
      // Додати блок контенту
      if (isSubtitle) {
        currentContent.push({
          type: 'text',
          title: line,
          description: null,
          order: order++
        });
      } else {
        // Якщо останній блок - текст без опису, додати до нього
        if (currentContent.length > 0 && 
            currentContent[currentContent.length - 1].type === 'text' && 
            !currentContent[currentContent.length - 1].description) {
          currentContent[currentContent.length - 1].description = line;
        } else {
          // Створити новий текстовий блок
          currentContent.push({
            type: 'text',
            title: '',
            description: line,
            order: order++
          });
        }
      }
    }
  }
  
  // Додати останню статтю
  if (currentArticle) {
    if (currentContent.length > 0) {
      currentArticle.contents = currentContent;
    }
    articles.push(currentArticle);
  }
  
  return articles;
}

// Основна функція
function convertNewsToJson() {
  const inputFile = path.join(__dirname, 'news-upload.txt');
  const outputFile = path.join(__dirname, 'admin-panel-backend', 'news.json');
  
  console.log('📰 Парсинг файлу news-upload.txt...');
  
  const articles = parseNewsFile(inputFile);
  
  console.log(`✅ Знайдено ${articles.length} статей`);
  
  // Створити JSON структуру
  const jsonData = {
    news: articles
  };
  
  // Записати JSON файл
  fs.writeFileSync(outputFile, JSON.stringify(jsonData, null, 2), 'utf-8');
  
  console.log(`✅ JSON файл створено: ${outputFile}`);
  console.log(`\n📊 Статистика:`);
  console.log(`   - Всього статей: ${articles.length}`);
  articles.forEach((article, index) => {
    console.log(`   ${index + 1}. "${article.title}" - ${article.contents.length} блоків контенту`);
  });
}

// Запуск
convertNewsToJson();

