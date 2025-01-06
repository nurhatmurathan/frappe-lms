<template>
	<Dialog v-model="show" :options="{ size: '4xl' }">
		<template #body>
			<div class="flex h-[calc(100vh_-_8rem)]">
				<div class="flex flex-col p-2 w-52 shrink-0 bg-gray-50">
					<h1 class="px-2 pt-2 mb-3 text-lg font-semibold">
						{{ __('Настройки') }}
					</h1>
					<div v-for="tab in tabs" :key="tab.label">
						<div
							v-if="!tab.hideLabel"
							class="mb-2 mt-3 flex cursor-pointer gap-1.5 px-1 text-base font-medium text-gray-600 transition-all duration-300 ease-in-out"
						>
							<span>{{ __(tab.label) }}</span>
						</div>
						<nav class="space-y-1">
							<SidebarLink
								v-for="item in tab.items"
								:link="item"
								:key="item.label"
								class="w-full"
								:class="
									activeTab?.label == item.label
										? 'bg-white shadow-sm'
										: 'hover:bg-gray-100'
								"
								@click="activeTab = item"
							/>
						</nav>
					</div>
				</div>
				<div
					v-if="activeTab && data.doc"
					:key="activeTab.label"
					class="flex flex-col flex-1 px-10 py-8"
				>
					<Members
						v-if="activeTab.label === 'Участники'"
						:label="activeTab.label"
						:description="activeTab.description"
						v-model:show="show"
					/>
					<Categories
						v-else-if="activeTab.label === 'Категории'"
						:label="activeTab.label"
						:description="activeTab.description"
					/>
					<PaymentSettings
						v-else-if="activeTab.label === 'Платежный шлюз'"
						:label="activeTab.label"
						:description="activeTab.description"
						:data="data"
						:fields="activeTab.fields"
					/>
					<BrandSettings
						v-else-if="activeTab.label === 'Брендинг'"
						:label="activeTab.label"
						:description="activeTab.description"
						:fields="activeTab.fields"
						:data="branding"
					/>
					<SettingDetails
						v-else
						:fields="activeTab.fields"
						:label="activeTab.label"
						:description="activeTab.description"
						:data="data"
					/>
				</div>
			</div>
		</template>
	</Dialog>
</template>
<script setup>
import { Dialog, createDocumentResource, createResource } from 'frappe-ui'
import { ref, computed, watch } from 'vue'
import { useSettings } from '@/stores/settings'
import SettingDetails from '../SettingDetails.vue'
import SidebarLink from '@/components/SidebarLink.vue'
import Members from '@/components/Members.vue'
import Categories from '@/components/Categories.vue'
import BrandSettings from '@/components/BrandSettings.vue'
import PaymentSettings from '@/components/PaymentSettings.vue'

const show = defineModel()
const doctype = ref('LMS Settings')
const activeTab = ref(null)
const settingsStore = useSettings()

const data = createDocumentResource({
	doctype: doctype.value,
	name: doctype.value,
	fields: ['*'],
	cache: doctype.value,
	auto: true,
})

const branding = createResource({
	url: 'lms.lms.api.get_branding',
	auto: true,
	cache: 'brand',
})

const tabsStructure = computed(() => {
	return [
		{
			label: 'Настройки',
			hideLabel: true,
			items: [
				{
					label: 'Общие',
					icon: 'Wrench',
					fields: [
						{
							label: 'Включить учебные пути',
							name: 'enable_learning_paths',
							description:
								'Это заставит студентов проходить назначенные им программы в правильном порядке.',
							type: 'checkbox',
						},
						{
							label: 'Отправлять приглашение в календарь для оценок',
							name: 'send_calendar_invite_for_evaluations',
							description:
								'Если включено, отправляет приглашение в Google Календарь студенту для оценок.',
							type: 'checkbox',
						},
						{
							label: 'Ключ доступа Unsplash',
							name: 'unsplash_access_key',
							description:
								'Необязательно. Если это установлено, студенты могут выбрать обложку из библиотеки Unsplash для своей страницы профиля. https://unsplash.com/documentation#getting-started.',
							type: 'text',
						},
					],
				},
			],
		},
		{
			label: 'Настройки',
			hideLabel: true,
			items: [
				{
					label: 'Платежный шлюз',
					icon: 'DollarSign',
					description:
						'Настройте платежный шлюз и другие параметры, связанные с платежами',
					fields: [
						{
							label: 'Платежный шлюз',
							name: 'payment_gateway',
							type: 'Link',
							doctype: 'Payment Gateway',
						},
						{
							label: 'Валюта по умолчанию',
							name: 'default_currency',
							type: 'Link',
							doctype: 'Currency',
						},
						{
							label: 'Применить НДС для Индии',
							name: 'apply_gst',
							type: 'checkbox',
						},
						{
							label: 'Показать эквивалентную сумму в долларах США',
							name: 'show_usd_equivalent',
							type: 'checkbox',
						},
						{
							label: 'Применить округление на эквивалент',
							name: 'apply_rounding',
							type: 'checkbox',
						},
					],
				},
			],
		},
		{
			label: 'Списки',
			hideLabel: false,
			items: [
				{
					label: 'Участники',
					description: 'Управление участниками вашей системы обучения',
					icon: 'UserRoundPlus',
				},
				{
					label: 'Категории',
					description: 'Управление категориями вашей системы обучения',
					icon: 'Network',
				},
			],
		},
		{
			label: 'Настроить',
			hideLabel: false,
			items: [
				{
					label: 'Брендинг',
					icon: 'Blocks',
					fields: [
						{
							label: 'Название бренда',
							name: 'app_name',
							type: 'text',
						},
						{
							label: 'Логотип',
							name: 'banner_image',
							type: 'Upload',
						},
						{
							label: 'Фавикон',
							name: 'favicon',
							type: 'Upload',
						},
						{
							label: 'Логотип в подвале',
							name: 'footer_logo',
							type: 'Upload',
						},
						{
							label: 'Адрес',
							name: 'address',
							type: 'textarea',
							rows: 2,
						},
						{
							label: 'Подвал "Powered By"',
							name: 'footer_powered',
							type: 'textarea',
							rows: 4,
						},
						{
							label: 'Авторские права',
							name: 'copyright',
							type: 'text',
						},
					],
				},
				{
					label: 'Боковая панель',
					icon: 'PanelLeftIcon',
					description:
						'Выберите элементы, которые вы хотите показать на боковой панели',
					fields: [
						{
							label: 'Курсы',
							name: 'courses',
							type: 'checkbox',
						},
						{
							label: 'Партии',
							name: 'batches',
							type: 'checkbox',
						},
						{
							label: 'Сертифицированные участники',
							name: 'certified_participants',
							type: 'checkbox',
						},
						{
							type: 'Column Break',
						},
						{
							label: 'Работы',
							name: 'jobs',
							type: 'checkbox',
						},
						{
							label: 'Статистика',
							name: 'statistics',
							type: 'checkbox',
						},
						{
							label: 'Уведомления',
							name: 'notifications',
							type: 'checkbox',
						},
					],
				},
				{
					label: 'Шаблоны электронной почты',
					icon: 'MailPlus',
					fields: [
						{
							label: 'Шаблон подтверждения партии',
							name: 'batch_confirmation_template',
							doctype: 'Email Template',
							type: 'Link',
						},
						{
							label: 'Шаблон сертификации',
							name: 'certification_template',
							doctype: 'Email Template',
							type: 'Link',
						},
						{
							label: 'Шаблон отправки задания',
							name: 'assignment_submission_template',
							doctype: 'Email Template',
							type: 'Link',
						},
					],
				},
				{
					label: 'Регистрация',
					icon: 'LogIn',
					fields: [
						{
							label: 'Пользовательский контент',
							name: 'custom_signup_content',
							type: 'Code',
							mode: 'htmlmixed',
							rows: 10,
						},
						{
							label: 'Спросить о профессии',
							name: 'user_category',
							type: 'checkbox',
							description:
								'Включите эту опцию, чтобы попросить пользователей выбрать свою профессию во время процесса регистрации.',
						},
					],
				},
			],
		},
	]
})

const tabs = computed(() => {
	return tabsStructure.value.map((tab) => {
		return {
			...tab,
			items: tab.items.filter((item) => {
				return !item.condition || item.condition()
			}),
		}
	})
})

watch(show, async () => {
	if (show.value) {
		const currentTab = await tabs.value
			.flatMap((tab) => tab.items)
			.find((item) => item.label === settingsStore.activeTab)
		activeTab.value = currentTab || tabs.value[0].items[0]
	} else {
		activeTab.value = null
		settingsStore.isSettingsOpen = false
	}
})
</script>
