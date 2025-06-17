create database books;

-- 1. roles 表：定义系统中的角色（管理员、店主、用户等）
CREATE TABLE roles (
    role_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '角色ID',
    role_name VARCHAR(50) UNIQUE NOT NULL COMMENT '角色名称'
) COMMENT='用户角色表';

-- 2. permissions 表：定义可操作的权限项（如订单管理、图书上新等）
CREATE TABLE permissions (
    permission_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '权限ID',
    name VARCHAR(100) UNIQUE NOT NULL COMMENT '权限名称'
) COMMENT='权限表';

-- 3. role_permission 表：角色与权限的多对多映射关系
CREATE TABLE role_permission (
    role_id INT COMMENT '角色ID',
    permission_id INT COMMENT '权限ID',
    PRIMARY KEY (role_id, permission_id),
    FOREIGN KEY (role_id) REFERENCES roles(role_id),
    FOREIGN KEY (permission_id) REFERENCES permissions(permission_id)
) COMMENT='角色-权限映射表';

-- 4. users 表：存储所有用户（含后台管理员和前台用户）；
-- 注册时写入users
CREATE TABLE users (
    user_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '用户ID',
    username VARCHAR(50) UNIQUE NOT NULL COMMENT '用户名',
    password_hash VARCHAR(255) NOT NULL COMMENT '密码哈希',
    email VARCHAR(100) UNIQUE COMMENT '邮箱',
    role_id INT COMMENT '角色ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '注册时间',
    FOREIGN KEY (role_id) REFERENCES roles(role_id)
) COMMENT='用户表';

-- 5. stores 表：记录图书店铺信息，每个店铺归属一个用户

CREATE TABLE stores (
    store_id INT PRIMARY KEY AUTO_INCREMENT COMMENT '店铺ID',
    name VARCHAR(100) NOT NULL COMMENT '店铺名称',
    owner_id BIGINT COMMENT '所属用户ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '店铺创建时间',
    FOREIGN KEY (owner_id) REFERENCES users(user_id)
) COMMENT='图书店铺表';

-- 6. books 表：记录图书信息，每本图书属于一个店铺；
-- 首页图书展示books表
CREATE TABLE books (
    book_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '图书ID',
    title VARCHAR(200) NOT NULL COMMENT '书名',
    author VARCHAR(100) NOT NULL COMMENT '作者',
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0) COMMENT '价格',
    category VARCHAR(100) COMMENT '分类',
    store_id INT COMMENT '所属店铺ID',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '上架时间',
    FOREIGN KEY (store_id) REFERENCES stores(store_id)
) COMMENT='图书表';

-- 7. orders 表：用户下单记录

CREATE TABLE orders (
    order_id BIGINT PRIMARY KEY AUTO_INCREMENT COMMENT '订单ID',
    user_id BIGINT COMMENT '下单用户ID',
    total_price DECIMAL(10,2) NOT NULL CHECK (total_price >= 0) COMMENT '总价',
    status VARCHAR(50) DEFAULT 'unpaid' COMMENT '订单状态',
    created_at DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '下单时间',
    FOREIGN KEY (user_id) REFERENCES users(user_id)
) COMMENT='订单主表';

-- 8. order_items 表：订单明细记录，每条记录为订单中的一个图书项
CREATE TABLE order_items (
    order_id BIGINT COMMENT '订单ID',
    book_id BIGINT COMMENT '图书ID',
    quantity INT NOT NULL CHECK (quantity > 0) COMMENT '购买数量',
    price DECIMAL(10,2) NOT NULL CHECK (price >= 0) COMMENT '购买时单价',
    PRIMARY KEY (order_id, book_id),
    FOREIGN KEY (order_id) REFERENCES orders(order_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
) COMMENT='订单详情表';

-- 9. cart_items 表：用户购物车中添加的图书项
-- 用户购物车
CREATE TABLE cart_items (
    user_id BIGINT COMMENT '用户ID',
    book_id BIGINT COMMENT '图书ID',
    quantity INT NOT NULL CHECK (quantity > 0) COMMENT '购物车数量',
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
) COMMENT='购物车表';

-- 10. book_recommendations 表：个性化推荐记录（一本书推荐给一个用户一次）
CREATE TABLE book_recommendations (
    user_id BIGINT COMMENT '用户ID',
    book_id BIGINT COMMENT '图书ID',
    score FLOAT COMMENT '推荐得分',
    reason VARCHAR(255) COMMENT '推荐理由',
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT '推荐时间',
    PRIMARY KEY (user_id, book_id),
    FOREIGN KEY (user_id) REFERENCES users(user_id),
    FOREIGN KEY (book_id) REFERENCES books(book_id)
) COMMENT='推荐记录表';

-- 11. book_stats 表：记录每本书的浏览次数和销量
-- 详情页显示某本书 + book_stats 浏览数/销量
CREATE TABLE book_stats (
    book_id BIGINT PRIMARY KEY COMMENT '图书ID',
    view_count INT DEFAULT 0 COMMENT '浏览次数',
    sales_count INT DEFAULT 0 COMMENT '销量',
    FOREIGN KEY (book_id) REFERENCES books(book_id)
) COMMENT='图书统计表';


-- 插入角色（admin, store_owner, customer）
INSERT INTO roles (role_name) VALUES
('admin'),           -- 管理员
('store_owner'),     -- 店主
('customer');        -- 普通用户

-- 插入权限列表
INSERT INTO permissions (name) VALUES
('manage_users'),    -- 管理用户权限
('manage_books'),    -- 管理图书权限
('manage_orders'),   -- 管理订单权限
('view_reports');    -- 查看报表权限

-- 分配权限给角色
-- admin 拥有所有权限，store_owner 有部分权限，customer 暂无权限
INSERT INTO role_permission (role_id, permission_id) VALUES
(1, 1), (1, 2), (1, 3), (1, 4),   -- admin
(2, 2), (2, 3);                  -- store_owner

-- 插入测试用户
INSERT INTO users (username, password_hash, email, role_id) VALUES
('admin1', 'adminpasshash', 'admin@example.com', 1),  -- 管理员
('owner1', 'ownerpasshash', 'owner@example.com', 2),  -- 店主
('user1', 'userpasshash', 'user1@example.com', 3);     -- 普通用户

-- 插入店铺（由 owner1 拥有）
INSERT INTO stores (name, owner_id) VALUES
('BookStore Alpha', 2);  -- 店主 ID = 2

-- 插入图书（属于店铺 BookStore Alpha）
INSERT INTO books (title, author, price, category, store_id) VALUES
('The Art of Database', 'Tom Data', 79.99, 'Tech', 1),       -- 技术类
('Learn SQL in 10 Days', 'Jane Query', 59.50, 'Tech', 1),    -- 技术类
('Mystery of Time', 'A. Clockman', 35.00, 'Fiction', 1);     -- 小说类

-- 初始化图书浏览量与销量
INSERT INTO book_stats (book_id, view_count, sales_count) VALUES
(1, 150, 25),   -- 第1本书
(2, 90, 10),    -- 第2本书
(3, 45, 5);     -- 第3本书

-- 添加购物车内容（user1 购物车中添加两本书）
INSERT INTO cart_items (user_id, book_id, quantity) VALUES
(3, 1, 1),   -- 添加第1本书 1本
(3, 2, 2);   -- 添加第2本书 2本

-- 插入订单记录（user1 已支付订单）
INSERT INTO orders (user_id, total_price, status) VALUES
(3, 198.99, 'paid');  -- 用户3下单

-- 插入订单明细（包括2本书）
INSERT INTO order_items (order_id, book_id, quantity, price) VALUES
(1, 1, 1, 79.99),   -- 1本书A
(1, 2, 2, 59.50);   -- 2本书B

-- 插入个性化推荐记录（向 user1 推荐第3本书）
INSERT INTO book_recommendations (user_id, book_id, score, reason) VALUES
(3, 3, 0.92, 'Because you liked Fiction books');
