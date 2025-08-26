<template>
  <div class="app">
    <!-- Header -->
    <header class="app-header">
      <div class="header-left">
        <h1>Augment Token Manager</h1>

      </div>
      <div class="header-buttons">
        <!-- Feature buttons -->
        <button @click="showDatabaseConfig = true" class="btn info">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M12 3C7.58 3 4 4.79 4 7s3.58 4 8 4 8-1.79 8-4-3.58-4-8-4zM4 9v3c0 2.21 3.58 4 8 4s8-1.79 8-4V9c0 2.21-3.58 4-8 4s-8-1.79-8-4zM4 16v3c0 2.21 3.58 4 8 4s8-1.79 8-4v-3c0 2.21-3.58 4-8 4s-8-1.79-8-4z"/>
          </svg>
          数据库配置
        </button>
        <button @click="showTokenList = true" class="btn primary">
          <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
            <path d="M3 13h2v-2H3v2zm0 4h2v-2H3v2zm0-8h2V7H3v2zm4 4h14v-2H7v2zm0 4h14v-2H7v2zM7 7v2h14V7H7z"/>
          </svg>
          已保存Token
        </button>
      </div>
    </header>

    <!-- Main Content -->
    <main class="main-content">
      <div class="token-generator-main">
        <div class="generator-header">
          <div class="header-content">
            <div class="title-section">
              <h2>生成Augment Token</h2>
              <p>按照以下步骤获取你的Augment访问令牌</p>
            </div>
            <!-- Sync Status Component -->
            <div class="sync-status-container">
              <SyncStatus @show-status="showStatus" />
            </div>
          </div>
        </div>

        <div class="generator-body">
          <!-- 卡密输入区域 -->
          <div class="section">
            <h3>使用卡密获取Token</h3>
            <div class="field-container">
              <label>卡密:</label>
              <div class="card-key-container">
                <input
                  type="text"
                  v-model="cardKey"
                  placeholder="请输入您的卡密"
                  class="field-input"
                >
                <div v-if="quotaInfo" class="quota-info">
                  <span class="quota-item">总额度: {{ quotaInfo.total }}</span>
                  <span class="quota-item">剩余额度: {{ quotaInfo.remaining_quota }}</span>
                </div>
              </div>
            </div>
            <div class="button-container">
              <button
                @click="getTokenByKey"
                :class="['btn', 'primary', { loading: isGettingTokenByKey }]"
                :disabled="!cardKey.trim() || isGettingTokenByKey"
              >
                获取Token
              </button>
            </div>
          </div>






        </div>


      </div>
    </main>

    <!-- Token List Modal -->
    <TokenList
      v-if="showTokenList"
      :tokens="tokens"
      :isLoading="isLoading"
      :hasUnsavedChanges="hasUnsavedChanges"
      @close="showTokenList = false"
      @delete="deleteToken"
      @copy-success="showStatus"
      @add-token="showTokenForm"
      @refresh="(showMessage) => loadTokens(showMessage)"
      @open-portal="handleOpenPortal"
      @edit="handleEditToken"
      @save="saveTokensToFile"
      @token-updated="hasUnsavedChanges = true"
    />

    <!-- Token Form Modal -->
    <TokenForm
      v-if="showTokenFormModal"
      :token="editingToken"
      @close="closeTokenForm"
      @success="handleTokenFormSuccess"
      @show-status="showStatus"
      @update-token="handleUpdateToken"
      @add-token="handleAddTokenFromForm"
    />

    <!-- Portal打开方式选择对话框 -->
    <div v-if="showPortalDialog" class="portal-dialog-overlay" @click="showPortalDialog = false">
      <div class="portal-dialog" @click.stop>
        <h3>选择打开方式</h3>
        <div class="dialog-buttons">
          <button @click="copyPortalUrl" class="dialog-btn copy">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M16 1H4c-1.1 0-2 .9-2 2v14h2V3h12V1zm3 4H8c-1.1 0-2 .9-2 2v14c0 1.1.9 2 2 2h11c1.1 0 2-.9 2-2V7c0-1.1-.9-2-2-2zm0 16H8V7h11v14z"/>
            </svg>
            复制链接
          </button>
          <button @click="openPortalExternal" class="dialog-btn external">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z"/>
            </svg>
            外部打开
          </button>
          <button @click="openPortalInternal" class="dialog-btn internal">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            内置打开
          </button>
          <button @click="showPortalDialog = false" class="dialog-btn cancel">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
            不打开
          </button>
        </div>
      </div>
    </div>
    <!-- 删除确认对话框 -->
    <div v-if="showDeleteConfirm" class="portal-dialog-overlay" @click="cancelDelete">
      <div class="portal-dialog delete-confirm" @click.stop>
        <h3>确认删除</h3>
        <p>确定要删除这个Token吗？此操作无法撤销。</p>
        <div class="dialog-buttons">
          <button @click="cancelDelete" class="dialog-btn cancel">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
            取消
          </button>
          <button @click="confirmDelete" class="dialog-btn delete">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M6 19c0 1.1.9 2 2 2h8c1.1 0 2-.9 2-2V7H6v12zM19 4h-3.5l-1-1h-5l-1 1H5v2h14V4z"/>
            </svg>
            删除
          </button>
        </div>
      </div>
    </div>







    <!-- Database Config Modal -->
    <DatabaseConfig
      v-if="showDatabaseConfig"
      @close="showDatabaseConfig = false"
      @show-status="showStatus"
      @config-saved="handleDatabaseConfigSaved"
      @config-deleted="handleDatabaseConfigDeleted"
    />

    <!-- Status Messages -->
    <div
      v-if="statusMessage"
      :class="['status-toast', statusType]"
    >
      <span class="status-message">{{ statusMessage }}</span>
      <button @click="statusMessage = ''" class="status-close-btn" title="关闭">
        <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
          <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
        </svg>
      </button>
    </div>

    <!-- 授权URL打开方式选择对话框 -->
    <div v-if="showAuthUrlDialog" class="portal-dialog-overlay" @click="showAuthUrlDialog = false">
      <div class="portal-dialog" @click.stop>
        <h3>选择打开方式</h3>
        <div class="dialog-buttons">
          <button @click="openAuthUrlExternal" class="dialog-btn external">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.11 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z"/>
            </svg>
            外部打开
          </button>
          <button @click="openAuthUrlInternal" class="dialog-btn internal">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm-2 15l-5-5 1.41-1.41L10 14.17l7.59-7.59L19 8l-9 9z"/>
            </svg>
            内置打开
          </button>
          <button @click="showAuthUrlDialog = false" class="dialog-btn cancel">
            <svg width="16" height="16" viewBox="0 0 24 24" fill="currentColor">
              <path d="M19 6.41L17.59 5 12 10.59 6.41 5 5 6.41 10.59 12 5 17.59 6.41 19 12 13.41 17.59 19 19 17.59 13.41 12z"/>
            </svg>
            取消
          </button>
        </div>
      </div>
    </div>




  </div>
</template>

<script setup>
import { ref, onMounted, computed } from 'vue'
import { invoke } from '@tauri-apps/api/core'
import TokenCard from './components/TokenCard.vue'
import TokenList from './components/TokenList.vue'
import TokenForm from './components/TokenForm.vue'
import DatabaseConfig from './components/DatabaseConfig.vue'
import SyncStatus from './components/SyncStatus.vue'

// 简化的状态管理
const tokens = ref([])
const isLoading = ref(false)
const showTokenList = ref(false)

const showDatabaseConfig = ref(false)
const statusMessage = ref('')
const statusType = ref('info')
const hasUnsavedChanges = ref(false)

// 简化的工具函数
const createNewToken = (tenantUrl, accessToken, portalUrl = null, emailNote = null) => {
  return {
    id: 'token_' + Date.now() + '_' + Math.random().toString(36).substr(2, 9),
    tenant_url: tenantUrl,
    access_token: accessToken,
    created_at: new Date().toISOString(),
    portal_url: portalUrl,
    ban_status: null,
    portal_info: null,
    email_note: emailNote
  }
}

// 移除了复杂的自动保存、错误处理和回滚机制，保持简单

// Token generator data
const authUrl = ref('')
const authCode = ref('')
const tokenResult = ref(null)
const isGenerating = ref(false)
const isGettingToken = ref(false)
const portalUrl = ref('')
const emailNote = ref('')

// 新增卡密相关数据
const cardKey = ref('')
const isGettingTokenByKey = ref(false)



// 手动输入的Token信息
const manualAccessToken = ref('')
const manualTenantUrl = ref('')

// 额度信息
const quotaInfo = ref(null)

// Template refs
const authUrlInput = ref(null)
const accessTokenInput = ref(null)
const tenantUrlInput = ref(null)



// Portal dialog
const showPortalDialog = ref(false)
const currentPortalToken = ref(null)

// Delete confirmation dialog
const showDeleteConfirm = ref(false)
const tokenToDelete = ref(null)

// Auth URL dialog
const showAuthUrlDialog = ref(false)





// Token form dialog
const showTokenFormModal = ref(false)
const editingToken = ref(null)

// Computed properties
const canGetToken = computed(() => {
  return authUrl.value && authCode.value.trim().length > 0
})

// Methods
const showStatus = (message, type = 'info') => {
  statusMessage.value = message
  statusType.value = type

  // 根据消息类型设置不同的显示时间
  const displayTime = type === 'error' ? 15000 : type === 'success' ? 13000 : 12000

  setTimeout(() => {
    statusMessage.value = ''
  }, displayTime)
}

const loadTokens = async (showSuccessMessage = false) => {
  isLoading.value = true
  try {
    const jsonString = await invoke('load_tokens_json')
    tokens.value = JSON.parse(jsonString)
    hasUnsavedChanges.value = false
    if (showSuccessMessage) {
      showStatus('Token加载成功', 'success')
    }
  } catch (error) {
    showStatus(`加载Token失败: ${error}`, 'error')
    tokens.value = []
    hasUnsavedChanges.value = false
  } finally {
    isLoading.value = false
  }
}


const saveTokensToFile = async () => {
  try {
    const jsonString = JSON.stringify(tokens.value, null, 2)
    await invoke('save_tokens_json', { jsonString })
    hasUnsavedChanges.value = false
    showStatus('Token保存成功', 'success')
  } catch (error) {
    showStatus(`保存Token失败: ${error}`, 'error')
    throw error
  }
}


const deleteToken = (tokenId) => {
  // 显示删除确认对话框
  tokenToDelete.value = tokenId
  showDeleteConfirm.value = true
}

const confirmDelete = async () => {
  if (!tokenToDelete.value) return

  try {
    // 调用后端删除 token
    const deleted = await invoke('delete_token', { tokenId: tokenToDelete.value })

    if (deleted) {
      // 从内存中也删除 token
      tokens.value = tokens.value.filter(token => token.id !== tokenToDelete.value)
      showStatus('Token已删除', 'success')
    } else {
      showStatus('Token删除失败：未找到指定token', 'error')
    }
  } catch (error) {
    showStatus(`删除Token失败: ${error}`, 'error')
  }

  showDeleteConfirm.value = false
  tokenToDelete.value = null
}


const cancelDelete = () => {
  showDeleteConfirm.value = false
  tokenToDelete.value = null
}



const onTokenSaved = () => {
  loadTokens()
  showStatus('新Token已保存!', 'success')
}

// Token generator methods
const copyToClipboard = async (text) => {
  try {
    await navigator.clipboard.writeText(text)
    return true
  } catch (error) {
    console.error('Failed to copy to clipboard:', error)
    return false
  }
}





const generateAuthUrl = async () => {
  isGenerating.value = true

  try {
    const url = await invoke('generate_augment_auth_url')
    authUrl.value = url
  } catch (error) {
    showStatus(`错误: ${error}`, 'error')
  } finally {
    isGenerating.value = false
  }
}

const copyAuthUrl = async () => {
  const success = await copyToClipboard(authUrl.value)
  showStatus(
    success ? 'URL已复制到剪贴板!' : '复制URL失败',
    success ? 'success' : 'error'
  )
}

const getAccessToken = async () => {
  isGettingToken.value = true
  showStatus('正在获取访问令牌...', 'info')

  try {
    const result = await invoke('get_augment_token', { code: authCode.value })
    tokenResult.value = result
    // 同时更新显示字段
    manualAccessToken.value = result.access_token
    manualTenantUrl.value = result.tenant_url
    showStatus('访问令牌获取成功!', 'success')
  } catch (error) {
    showStatus(`错误: ${error}`, 'error')
  } finally {
    isGettingToken.value = false
  }
}

// 获取显示的访问令牌
const getDisplayAccessToken = () => {
  return tokenResult.value ? tokenResult.value.access_token : manualAccessToken.value
}

// 获取显示的租户URL
const getDisplayTenantUrl = () => {
  return tokenResult.value ? tokenResult.value.tenant_url : manualTenantUrl.value
}

// 检查是否可以保存Token
const canSaveToken = () => {
  const accessToken = getDisplayAccessToken()
  const tenantUrl = getDisplayTenantUrl()
  return accessToken && tenantUrl
}

const copyAccessToken = async () => {
  const accessToken = getDisplayAccessToken()
  if (!accessToken) {
    showStatus('没有可复制的访问令牌', 'error')
    return
  }

  const success = await copyToClipboard(accessToken)
  showStatus(
    success ? '访问令牌已复制到剪贴板!' : '复制访问令牌失败',
    success ? 'success' : 'error'
  )
}

const copyTenantUrl = async () => {
  const tenantUrl = getDisplayTenantUrl()
  if (!tenantUrl) {
    showStatus('没有可复制的租户URL', 'error')
    return
  }

  const success = await copyToClipboard(tenantUrl)
  showStatus(
    success ? '租户URL已复制到剪贴板!' : '复制租户URL失败',
    success ? 'success' : 'error'
  )
}

// 清空Token表单（保留卡密和额度信息）
const clearTokenForm = () => {
  manualAccessToken.value = ''
  manualTenantUrl.value = ''
  tokenResult.value = null
  emailNote.value = ''
  authCode.value = ''
  authUrl.value = ''
  // 不清空 cardKey 和 quotaInfo，保留用户输入的卡密和额度信息
}

// 自动保存Token并显示Token列表
const autoSaveAndShowTokens = async () => {
  try {
    const accessToken = getDisplayAccessToken()
    const tenantUrl = getDisplayTenantUrl()

    if (!accessToken || !tenantUrl) {
      showStatus('Token信息不完整，无法自动保存', 'error')
      return
    }

    // 创建新的 token 对象
    const newToken = createNewToken(
      tenantUrl,
      accessToken,
      null, // Portal URL 不再使用
      emailNote.value.trim() || null
    )

    // 添加从接口获取的额外信息
    if (quotaInfo.value) {
      newToken.regist_date = quotaInfo.value.regist_date
      newToken.mdate_date = quotaInfo.value.mdate_date
    }

    // 添加到内存中的 tokens 数组
    tokens.value.push(newToken)
    hasUnsavedChanges.value = true

    showStatus('Token已自动保存到内存', 'success')

    // 延迟一下让用户看到成功消息，然后自动打开Token列表
    setTimeout(() => {
      showTokenList.value = true
      // 再延迟一下自动点击保存按钮
      setTimeout(() => {
        autoClickSaveButton()
      }, 500)
    }, 1000)

    // 不清空表单，保留卡密和额度信息供用户查看
  } catch (error) {
    showStatus(`自动保存Token失败: ${error}`, 'error')
  }
}

// 新增：通过卡密获取Token的方法
const getTokenByKey = async () => {
  if (!cardKey.value.trim()) {
    showStatus('请输入卡密', 'error')
    return
  }

  isGettingTokenByKey.value = true
  showStatus('正在获取Token...', 'info')

  try {
    const url = `https://aug.zhinianblog.cn/getAugmentToken.php?key=${encodeURIComponent(cardKey.value.trim())}`

    const response = await fetch(url, {
      method: 'GET',
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json'
      }
    })

    if (!response.ok) {
      throw new Error(`HTTP error! status: ${response.status}`)
    }

    const result = await response.json()

    if (result.success) {
      // 接口返回成功，将数据填入对应字段
      manualAccessToken.value = result.data.content
      manualTenantUrl.value = result.data.zuhu
      emailNote.value = result.data.email || ''

      // 保存额度信息和时间信息
      quotaInfo.value = {
        total: result.data.total,
        remaining_quota: result.data.remaining_quota,
        regist_date: result.data.regist_date,
        mdate_date: result.data.mdate_date
      }

      // 同时也放入步骤2的授权码框中（如果用户需要查看原始数据）
      authCode.value = JSON.stringify(result.data, null, 2)
      showStatus(`获取成功！剩余额度: ${result.data.remaining_quota}`, 'success')

      // 自动保存Token并打开已保存Token界面
      await autoSaveAndShowTokens()
    } else {
      // 接口返回失败
      showStatus(`获取失败: ${result.message}`, 'error')
      // 清空额度信息
      quotaInfo.value = null
    }
  } catch (error) {
    console.error('获取Token失败:', error)
    showStatus(`获取Token失败: ${error.message}`, 'error')
  } finally {
    isGettingTokenByKey.value = false
  }
}

const saveToken = async () => {
  try {
    const accessToken = getDisplayAccessToken()
    const tenantUrl = getDisplayTenantUrl()

    if (!accessToken || !tenantUrl) {
      showStatus('请确保访问令牌和租户URL都已填写', 'error')
      return
    }

    // 创建新的 token 对象
    const newToken = createNewToken(
      tenantUrl,
      accessToken,
      null, // Portal URL 不再使用
      emailNote.value.trim() || null
    )

    // 添加到内存中的 tokens 数组
    tokens.value.push(newToken)
    hasUnsavedChanges.value = true

    showStatus('Token已添加到内存，请手动保存', 'success')

    // Reset form
    clearTokenForm()
  } catch (error) {
    showStatus(`添加Token失败: ${error}`, 'error')
  }
}

// 自动点击保存按钮
const autoClickSaveButton = async () => {
  try {
    // 由于保存按钮已隐藏，直接调用保存方法
    if (hasUnsavedChanges.value) {
      await saveTokensToFile()
      showStatus('已自动保存到文件', 'success')
    } else {
      showStatus('Token已是最新状态，无需保存', 'info')
    }
  } catch (error) {
    console.error('自动保存失败:', error)
    showStatus('自动保存到文件失败', 'error')
  }
}

// Auth URL dialog methods
const openAuthUrlExternal = async () => {
  showAuthUrlDialog.value = false
  if (!authUrl.value) return

  try {
    await invoke('open_url', { url: authUrl.value })
  } catch (error) {
    console.error('Failed to open auth URL externally:', error)
    showStatus('打开授权URL失败', 'error')
  }
}

const openAuthUrlInternal = async () => {
  showAuthUrlDialog.value = false
  if (!authUrl.value) return

  try {
    await invoke('open_internal_browser', {
      url: authUrl.value,
      title: 'Augment OAuth 授权'
    })
  } catch (error) {
    console.error('Failed to open auth URL internally:', error)
    showStatus('打开授权URL失败', 'error')
  }
}




// Token form methods
const showTokenForm = () => {
  editingToken.value = null
  showTokenFormModal.value = true
}

const handleEditToken = (token) => {
  editingToken.value = token
  showTokenFormModal.value = true
}

const closeTokenForm = () => {
  showTokenFormModal.value = false
  editingToken.value = null
}

const handleTokenFormSuccess = () => {
  // TokenForm 现在只更新内存，不需要重新加载
  hasUnsavedChanges.value = true
}

const handleUpdateToken = (updatedTokenData) => {
  // 在内存中更新 token
  const index = tokens.value.findIndex(t => t.id === updatedTokenData.id)
  if (index !== -1) {
    tokens.value[index] = {
      ...tokens.value[index],
      tenant_url: updatedTokenData.tenantUrl,
      access_token: updatedTokenData.accessToken,
      portal_url: updatedTokenData.portalUrl,
      email_note: updatedTokenData.emailNote
    }
    hasUnsavedChanges.value = true
  }
}

const handleAddTokenFromForm = (tokenData) => {
  // 从表单添加新 token 到内存
  const newToken = createNewToken(
    tokenData.tenantUrl,
    tokenData.accessToken,
    tokenData.portalUrl,
    tokenData.emailNote
  )
  tokens.value.push(newToken)
  hasUnsavedChanges.value = true
}

const saveTokenManually = async (tenantUrl, accessToken, portalUrl, emailNote) => {
  try {
    // 创建新的 token 对象
    const newToken = createNewToken(
      tenantUrl,
      accessToken,
      portalUrl || null,
      emailNote || null
    )

    // 添加到内存中的 tokens 数组
    tokens.value.push(newToken)
    hasUnsavedChanges.value = true

    showStatus('Token已添加到内存，请手动保存', 'success')
    return { success: true }
  } catch (error) {
    showStatus(`添加Token失败: ${error}`, 'error')
    return { success: false, error }
  }
}

// Portal dialog methods
const handleOpenPortal = (token) => {
  currentPortalToken.value = token
  showPortalDialog.value = true
}

const copyPortalUrl = async () => {
  showPortalDialog.value = false
  if (!currentPortalToken.value?.portal_url) return

  const success = await copyToClipboard(currentPortalToken.value.portal_url)
  showStatus(
    success ? 'Portal链接已复制到剪贴板!' : '复制Portal链接失败',
    success ? 'success' : 'error'
  )
}

const openPortalExternal = async () => {
  showPortalDialog.value = false
  if (!currentPortalToken.value?.portal_url) return

  try {
    await invoke('open_url', { url: currentPortalToken.value.portal_url })
  } catch (error) {
    console.error('Failed to open portal externally:', error)
    showStatus('打开Portal失败', 'error')
  }
}

const openPortalInternal = async () => {
  showPortalDialog.value = false
  if (!currentPortalToken.value?.portal_url) return

  try {
    const displayUrl = currentPortalToken.value.tenant_url.replace(/^https?:\/\//, '').replace(/\/$/, '')
    await invoke('open_internal_browser', {
      url: currentPortalToken.value.portal_url,
      title: 'Portal - ' + displayUrl
    })
  } catch (error) {
    console.error('Failed to open portal internally:', error)
    showStatus('打开Portal失败', 'error')
  }
}







// Database config event handlers
const handleDatabaseConfigSaved = () => {
  showStatus('数据库配置已保存，存储功能已更新', 'success')
  // 可以在这里刷新同步状态或重新加载tokens
}

const handleDatabaseConfigDeleted = () => {
  showStatus('数据库配置已删除，已切换到仅本地存储', 'info')
  // 可以在这里刷新同步状态
}

// Initialize
onMounted(async () => {
  await loadTokens()
})


</script>

<style scoped>
.app {
  height: 100vh;
  background: #f8f9fa;
  overflow: hidden;
  display: flex;
  flex-direction: column;
}

/* 隐藏所有滚动条 */
* {
  scrollbar-width: none; /* Firefox */
  -ms-overflow-style: none; /* IE and Edge */
}

*::-webkit-scrollbar {
  width: 0px;
  background: transparent;
}

/* 确保body和html不产生滚动条 */
html, body {
  overflow: hidden;
  height: 100%;
  margin: 0;
  padding: 0;
}

.app-header {
  background: white;
  border-bottom: 1px solid #e1e5e9;
  padding: 12px 16px;
  display: flex;
  justify-content: space-between;
  align-items: center;
  box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
  flex-shrink: 0;
  min-height: 60px;
  flex-wrap: wrap;
  gap: 8px;
}

.header-left {
  display: flex;
  flex-direction: column;
  gap: 8px;
  flex: 1;
  min-width: 0;
  align-items: flex-start;
}

.app-header h1 {
  margin: 0;
  color: #333;
  font-size: 20px;
  font-weight: 600;
  white-space: nowrap;
}







.header-buttons {
  display: flex;
  gap: 8px;
  align-items: center;
  flex-wrap: wrap;
  justify-content: flex-end;
}





.main-content {
  padding: 20px 16px;
  flex: 1;
  overflow-y: auto;
  min-height: 0;
}

.sync-status-container {
  position: absolute;
  top: 0;
  right: -20px;
  display: flex;
  justify-content: flex-end;
  align-items: flex-start;
}

.sync-status-container > * {
  width: 240px;
  max-width: 30%;
}

.generator-header {
  margin-bottom: 32px;
}

.header-content {
  position: relative;
  display: flex;
  justify-content: center;
  align-items: flex-start;
  gap: 20px;
}

.title-section {
  text-align: center;
}

.title-section h2 {
  margin: 0 0 8px 0;
  font-size: 28px;
  font-weight: 700;
  color: #1f2937;
  line-height: 1.2;
}

.title-section p {
  margin: 0;
  font-size: 16px;
  color: #6b7280;
  line-height: 1.5;
}

.btn {
  padding: 10px 16px;
  border: none;
  border-radius: 6px;
  cursor: pointer;
  font-size: 14px;
  font-weight: 500;
  transition: all 0.2s;
  display: inline-flex;
  align-items: center;
  gap: 8px;
}

.btn.primary {
  background: #007bff;
  color: white;
}

.btn.primary:hover {
  background: #0056b3;
}

.btn.secondary {
  background: #6c757d;
  color: white;
}

.btn.secondary:hover {
  background: #545b62;
}

.btn.warning {
  background: #f59e0b;
  color: white;
}

.btn.warning:hover {
  background: #d97706;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(245, 158, 11, 0.3);
}

.btn.info {
  background: #0ea5e9;
  color: white;
}

.btn.info:hover {
  background: #0284c7;
  transform: translateY(-1px);
  box-shadow: 0 2px 4px rgba(14, 165, 233, 0.3);
}

.btn.small {
  padding: 6px 12px;
  font-size: 12px;
}

.btn.disabled,
.btn:disabled {
  opacity: 0.5;
  cursor: not-allowed;
  pointer-events: none;
}

.login-buttons {
  display: flex;
  gap: 6px;
  align-items: center;
}

/* 输入框样式 */
input[type="text"] {
  padding: 10px 12px;
  border: 1px solid #ddd;
  border-radius: 4px;
  font-size: 14px;
  transition: border-color 0.2s;
  width: 100%;
  box-sizing: border-box;
}

input[type="text"]:focus {
  outline: none;
  border-color: #007bff;
  box-shadow: 0 0 0 2px rgba(0, 123, 255, 0.1);
}

input[type="text"]:read-only {
  background-color: #f8f9fa;
  color: #6c757d;
}

/* 带复制图标的输入框 */
.input-with-copy {
  position: relative;
  display: flex;
  align-items: center;
  width: 100%;
}

.input-with-copy input {
  padding-right: 45px;
  flex: 1;
}

.copy-icon-btn {
  position: absolute;
  right: 8px;
  background: none;
  border: none;
  cursor: pointer;
  padding: 6px;
  border-radius: 4px;
  color: #6c757d;
  transition: all 0.2s;
  display: flex;
  align-items: center;
  justify-content: center;
}

.copy-icon-btn:hover {
  background: #e9ecef;
  color: #495057;
}

.copy-icon-btn:active {
  transform: scale(0.95);
}



/* 响应式设计 */
@media (max-width: 768px) {
  .app-header {
    padding: 8px 12px;
    min-height: 56px;
  }

  .app-header h1 {
    font-size: 18px;
  }

  .header-buttons {
    gap: 6px;
  }

  .btn {
    padding: 8px 12px;
    font-size: 13px;
  }

  .btn.small {
    padding: 6px 10px;
    font-size: 12px;
  }
}

/* Modal styles */
.modal-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 1000;
}

.modal-content {
  background: white;
  border-radius: 12px;
  max-width: 90vw;
  max-height: 95vh;
  overflow-y: auto;
  position: relative;
}

.modal-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  padding: 20px 24px;
  border-bottom: 1px solid #e5e7eb;
  background: #f9fafb;
  border-radius: 12px 12px 0 0;
}

.modal-header h3 {
  margin: 0;
  color: #374151;
  font-size: 18px;
  font-weight: 600;
}

.close-btn {
  background: none;
  border: none;
  font-size: 24px;
  cursor: pointer;
  color: #6b7280;
  padding: 0;
  width: 32px;
  height: 32px;
  display: flex;
  align-items: center;
  justify-content: center;
  border-radius: 6px;
  transition: all 0.2s;
}

.close-btn:hover {
  background: #e5e7eb;
  color: #374151;
}

@media (max-width: 480px) {
  .app-header {
    flex-direction: column;
    align-items: stretch;
    gap: 8px;
    padding: 8px;
  }

  .header-left {
    justify-content: space-between;
    width: 100%;
  }

  .header-buttons {
    justify-content: space-between;
    width: 100%;
  }

  .user-controls {
    margin-left: auto;
    padding-left: 8px;
    border-left: 1px solid #e1e5e9;
  }
}

.empty-state {
  text-align: center;
  padding: 40px 20px;
  color: #666;
}

.empty-icon {
  margin-bottom: 24px;
  color: #ccc;
}

.empty-state h2 {
  margin: 0 0 12px 0;
  color: #333;
  font-size: 24px;
  font-weight: 600;
}

.empty-state p {
  margin: 0;
  font-size: 16px;
  line-height: 1.5;
}

.loading-state {
  text-align: center;
  padding: 40px 20px;
  color: #666;
}

.spinner {
  width: 40px;
  height: 40px;
  border: 4px solid #f3f3f3;
  border-top: 4px solid #007bff;
  border-radius: 50%;
  animation: spin 1s linear infinite;
  margin: 0 auto 20px;
}

@keyframes spin {
  0% { transform: rotate(0deg); }
  100% { transform: rotate(360deg); }
}

.token-list {
  width: 100%;
}

.list-header {
  display: flex;
  justify-content: space-between;
  align-items: center;
  margin-bottom: 24px;
}

.list-header h2 {
  margin: 0;
  color: #333;
  font-size: 20px;
  font-weight: 600;
}

.status-toast {
  position: fixed;
  top: 20px;
  left: 20px;
  padding: 12px 20px;
  border-radius: 6px;
  font-size: 14px;
  font-weight: 500;
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.15);
  z-index: 1000;
  animation: slideIn 0.3s ease;
  display: flex;
  align-items: center;
  gap: 12px;
  max-width: 400px;
  word-wrap: break-word;
}

@keyframes slideIn {
  from {
    transform: translateX(100%);
    opacity: 0;
  }
  to {
    transform: translateX(0);
    opacity: 1;
  }
}

.status-toast.info {
  background: #d1ecf1;
  color: #0c5460;
  border: 1px solid #bee5eb;
}

.status-toast.success {
  background: #d4edda;
  color: #155724;
  border: 1px solid #c3e6cb;
}

.status-toast.error {
  background: #f8d7da;
  color: #721c24;
  border: 1px solid #f5c6cb;
}

.status-message {
  flex: 1;
  line-height: 1.4;
}

.status-close-btn {
  background: none;
  border: none;
  cursor: pointer;
  padding: 4px;
  border-radius: 4px;
  color: inherit;
  opacity: 0.7;
  transition: all 0.2s ease;
  display: flex;
  align-items: center;
  justify-content: center;
  flex-shrink: 0;
}

.status-close-btn:hover {
  opacity: 1;
  background: rgba(0, 0, 0, 0.1);
}

.status-close-btn:active {
  transform: scale(0.95);
}

/* Portal对话框样式 */
.portal-dialog-overlay {
  position: fixed;
  top: 0;
  left: 0;
  right: 0;
  bottom: 0;
  background: rgba(0, 0, 0, 0.5);
  display: flex;
  align-items: center;
  justify-content: center;
  z-index: 3000; /* 确保在所有其他元素之上 */
}

.portal-dialog {
  background: white;
  border-radius: 12px;
  padding: 24px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  min-width: 300px;
  max-width: 400px;
}

.portal-dialog h3 {
  margin: 0 0 20px 0;
  font-size: 18px;
  font-weight: 600;
  color: #333;
  text-align: center;
}

.dialog-buttons {
  display: flex;
  flex-direction: column;
  gap: 12px;
}

.dialog-btn {
  display: flex;
  align-items: center;
  gap: 8px;
  padding: 12px 16px;
  border: 2px solid transparent;
  border-radius: 8px;
  background: #f8f9fa;
  color: #495057;
  font-size: 14px;
  font-weight: 500;
  cursor: pointer;
  transition: all 0.2s ease;
  justify-content: center;
}

.dialog-btn:hover {
  transform: translateY(-1px);
  box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
}

.dialog-btn.external {
  background: #e3f2fd;
  color: #1976d2;
  border-color: #90caf9;
}

.dialog-btn.external:hover {
  background: #bbdefb;
  border-color: #64b5f6;
}

.dialog-btn.internal {
  background: #e8f5e8;
  color: #2e7d32;
  border-color: #a5d6a7;
}

.dialog-btn.internal:hover {
  background: #c8e6c9;
  border-color: #81c784;
}

.dialog-btn.cancel {
  background: #fce4ec;
  color: #c2185b;
  border-color: #f8bbd9;
}

.dialog-btn.cancel:hover {
  background: #f8bbd9;
  border-color: #f48fb1;
}

.dialog-btn.delete {
  background: #ffebee;
  color: #d32f2f;
  border-color: #ffcdd2;
}

.dialog-btn.delete:hover {
  background: #ffcdd2;
  border-color: #ef9a9a;
}

/* 删除确认对话框特定样式 */
.portal-dialog.delete-confirm p {
  margin: 0 0 20px 0;
  color: #666;
  text-align: center;
  line-height: 1.5;
}

.delete-confirm .dialog-buttons {
  flex-direction: row;
  gap: 12px;
}

.delete-confirm .dialog-btn {
  flex: 1;
}

.additional-fields {
  margin-top: 20px;
  padding-top: 20px;
  border-top: 1px solid #e1e5e9;
}

.field-container {
  margin-bottom: 15px;
}

.field-container label {
  display: block;
  margin-bottom: 5px;
  font-weight: 500;
  color: #374151;
  font-size: 14px;
}

.field-input {
  width: 100%;
  padding: 10px 12px;
  border: 1px solid #d1d5db;
  border-radius: 6px;
  font-size: 14px;
  transition: border-color 0.2s ease;
}

.field-input:focus {
  outline: none;
  border-color: #3b82f6;
  box-shadow: 0 0 0 3px rgba(59, 130, 246, 0.1);
}

.field-input::placeholder {
  color: #9ca3af;
}

/* 卡密容器样式 */
.card-key-container {
  display: flex;
  flex-direction: column;
  gap: 8px;
}

.quota-info {
  display: flex;
  gap: 16px;
  font-size: 13px;
  color: #6b7280;
  padding: 8px 12px;
  background: #f3f4f6;
  border-radius: 6px;
  border: 1px solid #e5e7eb;
}

.quota-item {
  display: flex;
  align-items: center;
  font-weight: 500;
}

.quota-item:first-child {
  color: #374151;
}

.quota-item:last-child {
  color: #059669;
  font-weight: 600;
}



/* 移除了重复的状态指示器样式，现在在 TokenList.vue 中 */

@media (max-width: 768px) {
  .app-header {
    padding: 16px 20px;
    flex-direction: column;
    gap: 16px;
    text-align: center;
  }

  .header-left {
    gap: 12px;
    align-items: center;
  }

  .header-buttons {
    flex-direction: column;
    width: 100%;
  }



  .header-buttons .btn {
    width: 100%;
    justify-content: center;
  }

  .main-content {
    padding: 20px 16px;
  }

  .header-content {
    flex-direction: column;
    gap: 16px;
  }

  .sync-status-container {
    position: static;
    justify-content: center;
  }

  .sync-status-container > * {
    width: 100%;
    max-width: 100%;
  }

  .title-section h2 {
    font-size: 24px;
  }

  .title-section p {
    font-size: 14px;
  }

  .list-header {
    flex-direction: column;
    gap: 16px;
    align-items: stretch;
  }

  .status-toast {
    left: 20px;
    right: 20px;
    top: auto;
    bottom: 20px;
  }
}
</style>
